import ARKit
import Flutter
import RoomPlan
import SceneKit
import UIKit

// LiDAR room scan with Apple RoomPlan (iOS 16+, LiDAR devices only). The
// app still supports iOS 15, so RoomPlan is weak-linked and everything that
// touches it is behind `#available(iOS 16, *)`.
//
// Dart side: lib/features/measure/screens/room_scan_screen.dart. Geometry
// goes to Dart in meters (y up); lib/features/measure/model/room_scan.dart
// turns it into a RoomSpec.

/// `kaiyaletz/room_scan` → `isSupported`: whether this device can scan.
enum RoomScanSupport {
  static func register(messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "kaiyaletz/room_scan", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        guard call.method == "isSupported" else { return result(FlutterMethodNotImplemented) }
        if #available(iOS 16, *) {
          result(RoomCaptureSession.isSupported)
        } else {
          result(false)
        }
      }
  }
}

/// Creates one [RoomScanView] per Flutter `UiKitView('kaiyaletz/room_scan_view')`.
final class RoomScanFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    if #available(iOS 16, *), RoomCaptureSession.isSupported {
      return RoomScanView(frame: frame, viewId: viewId, messenger: messenger)
    }
    // Dart only opens the scan when isSupported is true; this is a guard.
    return BlankPlatformView(frame: frame)
  }
}

private final class BlankPlatformView: NSObject, FlutterPlatformView {
  private let blank: UIView

  init(frame: CGRect) {
    blank = UIView(frame: frame)
    blank.backgroundColor = .black
    super.init()
  }

  func view() -> UIView { blank }
}

/// Camera view that runs a RoomCaptureSession and draws what it finds in
/// colour: walls blue (picked walls orange), doors yellow, windows cyan,
/// open passages white, sinks green, stoves red, other objects grey.
///
/// Commands (`kaiyaletz/room_scan_<viewId>`):
///   setSelection([wallId])  label these walls A, B, C in the view
///   finish                  stop and return the final room (see `summary`)
///   cancel                  stop without a result
/// Events (`kaiyaletz/room_scan_events_<viewId>`), at most 5 per second:
///   summary of the live room, plus `message` when the scan fails.
@available(iOS 16, *)
final class RoomScanView: NSObject, FlutterPlatformView, FlutterStreamHandler,
  RoomCaptureSessionDelegate
{
  private let sceneView = ARSCNView()
  private let captureSession = RoomCaptureSession()
  private let commands: FlutterMethodChannel
  private let events: FlutterEventChannel
  private var sink: FlutterEventSink?

  /// One node per wall, door, window, opening or object, by RoomPlan id.
  private var nodes: [UUID: SCNNode] = [:]
  private var selection: [String] = []
  private var latestRoom: CapturedRoom?
  private var instruction = "normal"
  private var lastEmit: TimeInterval = 0
  private var pendingFinish: FlutterResult?
  private var running = false

  init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {
    commands = FlutterMethodChannel(
      name: "kaiyaletz/room_scan_\(viewId)", binaryMessenger: messenger)
    events = FlutterEventChannel(
      name: "kaiyaletz/room_scan_events_\(viewId)", binaryMessenger: messenger)
    super.init()

    sceneView.frame = frame
    sceneView.session = captureSession.arSession
    sceneView.automaticallyUpdatesLighting = false
    sceneView.rendersCameraGrain = false

    commands.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return result(nil) }
      switch call.method {
      case "setSelection":
        self.selection = call.arguments as? [String] ?? []
        if let room = self.latestRoom { self.draw(room) }
        result(nil)
      case "finish":
        self.finish(result)
      case "cancel":
        self.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    events.setStreamHandler(self)

    captureSession.delegate = self
    var config = RoomCaptureSession.Configuration()
    config.isCoachingEnabled = true
    captureSession.run(configuration: config)
    running = true
  }

  deinit {
    stop()
    commands.setMethodCallHandler(nil)
    events.setStreamHandler(nil)
  }

  func view() -> UIView { sceneView }

  private func stop() {
    guard running else { return }
    running = false
    captureSession.stop()
  }

  /// Stops the scan; the result arrives in `didEndWith`.
  private func finish(_ result: @escaping FlutterResult) {
    guard pendingFinish == nil else {
      return result(FlutterError(code: "busy", message: "Already finishing", details: nil))
    }
    guard running else {
      // Already ended (e.g. interrupted): hand back what was seen live.
      return result(latestRoom.map { summary(of: $0) })
    }
    pendingFinish = result
    stop()
  }

  // MARK: - RoomCaptureSessionDelegate

  func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.latestRoom = room
      self.draw(room)
      let now = CACurrentMediaTime()
      if now - self.lastEmit > 0.2 {
        self.lastEmit = now
        self.emit(self.summary(of: room))
      }
    }
  }

  func captureSession(
    _ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.instruction = Self.name(of: instruction)
      self.emit(self.latestRoom.map { self.summary(of: $0) } ?? ["instruction": self.instruction])
    }
  }

  func captureSession(
    _ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.running = false
      let finish = self.pendingFinish
      self.pendingFinish = nil

      if let error = error {
        let message = "The scan stopped: \(error.localizedDescription) Start again."
        if let finish = finish {
          finish(FlutterError(code: "scanFailed", message: message, details: nil))
        } else {
          self.emit(["message": message])
        }
        return
      }
      guard let finish = finish else { return }

      // RoomBuilder straightens and squares up the live result.
      let live = self.latestRoom
      Task {
        let built = try? await RoomBuilder(options: [.beautifyObjects]).capturedRoom(from: data)
        await MainActor.run {
          if let room = built ?? live {
            finish(self.summary(of: room))
          } else {
            finish(FlutterError(code: "empty", message: "No walls were found.", details: nil))
          }
        }
      }
    }
  }

  // MARK: - Drawing

  private static let wallColor = UIColor.systemBlue
  private static let pickedColor = UIColor(red: 0.76, green: 0.57, blue: 0.40, alpha: 1)

  private func draw(_ room: CapturedRoom) {
    var seen = Set<UUID>()
    for wall in room.walls {
      let pick = selection.firstIndex(of: wall.identifier.uuidString)
      let node = surfaceNode(
        wall, color: pick == nil ? Self.wallColor : Self.pickedColor, order: 1)
      let length = String(format: "%.2f m", wall.dimensions.x)
      setLabel(
        on: node,
        pick.map { "\(String(UnicodeScalar(UInt8(65 + $0)))) · \(length)" } ?? length)
      seen.insert(wall.identifier)
    }
    for door in room.doors {
      _ = surfaceNode(door, color: .systemYellow, order: 2)
      seen.insert(door.identifier)
    }
    for window in room.windows {
      _ = surfaceNode(window, color: .cyan, order: 2)
      seen.insert(window.identifier)
    }
    for opening in room.openings {
      _ = surfaceNode(opening, color: .white, order: 2)
      seen.insert(opening.identifier)
    }
    for object in room.objects {
      let color: UIColor =
        switch object.category {
        case .sink: .systemGreen
        case .stove: .systemRed
        default: .systemGray
        }
      objectNode(object, color: color)
      seen.insert(object.identifier)
    }
    for (id, node) in nodes where !seen.contains(id) {
      node.removeFromParentNode()
      nodes[id] = nil
    }
  }

  /// A see-through rectangle for a wall, door, window or opening. Less
  /// sure surfaces are fainter.
  private func surfaceNode(_ s: CapturedRoom.Surface, color: UIColor, order: Int) -> SCNNode {
    let node = node(for: s.identifier)
    let plane = node.geometry as? SCNPlane ?? SCNPlane()
    plane.width = CGFloat(s.dimensions.x)
    plane.height = CGFloat(s.dimensions.y)
    plane.firstMaterial = Self.material(color, alpha: Self.alpha(s.confidence))
    node.geometry = plane
    node.renderingOrder = order
    // Surface space: x along the width, y up, z out of the wall, which is
    // also how SCNPlane is laid out.
    node.simdTransform = s.transform
    return node
  }

  private func objectNode(_ o: CapturedRoom.Object, color: UIColor) {
    let node = node(for: o.identifier)
    let box = node.geometry as? SCNBox ?? SCNBox()
    box.width = CGFloat(o.dimensions.x)
    box.height = CGFloat(o.dimensions.y)
    box.length = CGFloat(o.dimensions.z)
    box.chamferRadius = 0
    box.firstMaterial = Self.material(color, alpha: Self.alpha(o.confidence) * 0.8)
    node.geometry = box
    node.renderingOrder = 3
    node.simdTransform = o.transform
  }

  private func node(for id: UUID) -> SCNNode {
    if let node = nodes[id] { return node }
    let node = SCNNode()
    sceneView.scene.rootNode.addChildNode(node)
    nodes[id] = node
    return node
  }

  /// Wall length, always facing the camera, drawn over everything.
  private func setLabel(on parent: SCNNode, _ text: String) {
    let label: SCNNode
    if let existing = parent.childNode(withName: "label", recursively: false) {
      label = existing
      if (label.geometry as? SCNText)?.string as? String == text { return }
    } else {
      label = SCNNode()
      label.name = "label"
      label.scale = SCNVector3(0.01, 0.01, 0.01)  // 10 pt → 10 cm
      label.constraints = [SCNBillboardConstraint()]
      label.renderingOrder = 10
      parent.addChildNode(label)
    }
    let geometry = SCNText(string: text, extrusionDepth: 0)
    geometry.font = .systemFont(ofSize: 10, weight: .semibold)
    geometry.flatness = 0.1
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.white
    material.lightingModel = .constant
    material.readsFromDepthBuffer = false
    geometry.firstMaterial = material
    label.geometry = geometry
    let (lo, hi) = geometry.boundingBox
    label.pivot = SCNMatrix4MakeTranslation((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, 0)
  }

  private static func material(_ color: UIColor, alpha: CGFloat) -> SCNMaterial {
    let m = SCNMaterial()
    m.diffuse.contents = color.withAlphaComponent(alpha)
    m.lightingModel = .constant
    m.isDoubleSided = true
    m.blendMode = .alpha
    // Overlapping see-through shapes: draw in renderingOrder, don't hide
    // each other.
    m.writesToDepthBuffer = false
    return m
  }

  private static func alpha(_ confidence: CapturedRoom.Confidence) -> CGFloat {
    switch confidence {
    case .high: return 0.45
    case .medium: return 0.3
    case .low: return 0.15
    @unknown default: return 0.3
    }
  }

  // MARK: - Stream to Dart

  /// Plain lists and numbers, read by RoomScan.fromMap in Dart.
  private func summary(of room: CapturedRoom) -> [String: Any] {
    var items: [[String: Any]] = []
    for (list, kind) in [(room.doors, "door"), (room.windows, "window"), (room.openings, "opening")] {
      for s in list {
        items.append(item(id: s.identifier, kind: kind, s.transform, s.dimensions))
      }
    }
    for o in room.objects {
      let kind: String =
        switch o.category {
        case .sink: "sink"
        case .stove: "stove"
        default: "other"
        }
      items.append(item(id: o.identifier, kind: kind, o.transform, o.dimensions))
    }

    var payload: [String: Any] = [
      "walls": room.walls.map { wall -> [String: Any] in
        let c = Self.center(wall.transform)
        let x = simd_normalize(
          SIMD3(wall.transform.columns.0.x, wall.transform.columns.0.y, wall.transform.columns.0.z))
        let half = wall.dimensions.x / 2
        let a = c - x * half, b = c + x * half
        return [
          "id": wall.identifier.uuidString,
          "start": [Double(a.x), Double(a.z)],
          "end": [Double(b.x), Double(b.z)],
          "bottomY": Double(c.y - wall.dimensions.y / 2),
          "heightM": Double(wall.dimensions.y),
          "confidence": Self.name(of: wall.confidence),
        ]
      },
      "items": items,
      "instruction": instruction,
    ]
    if let camera = sceneView.session.currentFrame?.camera.transform.columns.3 {
      payload["camera"] = [Double(camera.x), Double(camera.z)]
    }
    return payload
  }

  private func item(
    id: UUID, kind: String, _ transform: simd_float4x4, _ dimensions: simd_float3
  ) -> [String: Any] {
    let c = Self.center(transform)
    return [
      "id": id.uuidString,
      "kind": kind,
      "center": [Double(c.x), Double(c.z)],
      "widthM": Double(dimensions.x),
      "heightM": Double(dimensions.y),
      "bottomY": Double(c.y - dimensions.y / 2),
    ]
  }

  private static func center(_ t: simd_float4x4) -> SIMD3<Float> {
    SIMD3(t.columns.3.x, t.columns.3.y, t.columns.3.z)
  }

  private static func name(of confidence: CapturedRoom.Confidence) -> String {
    switch confidence {
    case .high: return "high"
    case .medium: return "medium"
    case .low: return "low"
    @unknown default: return "medium"
    }
  }

  private static func name(of instruction: RoomCaptureSession.Instruction) -> String {
    switch instruction {
    case .moveCloseToWall: return "moveCloseToWall"
    case .moveAwayFromWall: return "moveAwayFromWall"
    case .slowDown: return "slowDown"
    case .turnOnLight: return "turnOnLight"
    case .lowTexture: return "lowTexture"
    case .normal: return "normal"
    @unknown default: return "normal"
    }
  }

  private func emit(_ payload: [String: Any]) {
    sink?(payload)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }
}
