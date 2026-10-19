import ARKit
import Flutter
import SceneKit
import UIKit

/// Creates one [ArMeasureView] per Flutter `UiKitView('kaiyaletz/ar_measure_view')`.
final class ArMeasureFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    ArMeasureView(frame: frame, viewId: viewId, messenger: messenger)
  }
}

/// ARKit camera view. Raycasts from the screen center every frame, pins points
/// on request, draws dots + lines, and streams state back to Dart.
final class ArMeasureView: NSObject, FlutterPlatformView, ARSCNViewDelegate, FlutterStreamHandler {
  private let sceneView = ARSCNView()
  private let commands: FlutterMethodChannel
  private let events: FlutterEventChannel
  private var sink: FlutterEventSink?

  private var points: [SIMD3<Float>] = []
  private var dotNodes: [SCNNode] = []
  private var lineNodes: [SCNNode] = []  // lineNodes[i] joins point i and i+1
  private var currentHit: SIMD3<Float>?
  private var lastEmit: TimeInterval = 0

  init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {
    commands = FlutterMethodChannel(
      name: "kaiyaletz/ar_measure_\(viewId)", binaryMessenger: messenger)
    events = FlutterEventChannel(
      name: "kaiyaletz/ar_measure_events_\(viewId)", binaryMessenger: messenger)
    super.init()

    sceneView.frame = frame
    sceneView.delegate = self
    sceneView.automaticallyUpdatesLighting = true

    commands.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "addPoint": self?.addPoint()
      case "undo": self?.undo()
      case "clear": self?.clear()
      default: return result(FlutterMethodNotImplemented)
      }
      result(nil)
    }
    events.setStreamHandler(self)

    guard ARWorldTrackingConfiguration.isSupported else {
      emit(message: "AR is not supported on this device.")
      return
    }
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal, .vertical]
    sceneView.session.run(config)
  }

  deinit {
    sceneView.session.pause()
    commands.setMethodCallHandler(nil)
    events.setStreamHandler(nil)
  }

  func view() -> UIView { sceneView }

  // MARK: - Commands

  private func addPoint() {
    guard let hit = currentHit else { return }
    let dot = SCNNode(geometry: SCNSphere(radius: 0.012))
    dot.geometry?.firstMaterial?.diffuse.contents = UIColor.systemOrange
    dot.simdPosition = hit
    sceneView.scene.rootNode.addChildNode(dot)
    dotNodes.append(dot)

    if let prev = points.last {
      let line = lineNode(from: prev, to: hit)
      sceneView.scene.rootNode.addChildNode(line)
      lineNodes.append(line)
    }
    points.append(hit)
    emit()
  }

  private func undo() {
    guard !points.isEmpty else { return }
    points.removeLast()
    dotNodes.removeLast().removeFromParentNode()
    if !lineNodes.isEmpty { lineNodes.removeLast().removeFromParentNode() }
    emit()
  }

  private func clear() {
    (dotNodes + lineNodes).forEach { $0.removeFromParentNode() }
    points.removeAll()
    dotNodes.removeAll()
    lineNodes.removeAll()
    emit()
  }

  /// A thin cylinder stretched between [a] and [b].
  private func lineNode(from a: SIMD3<Float>, to b: SIMD3<Float>) -> SCNNode {
    let cylinder = SCNCylinder(radius: 0.003, height: CGFloat(simd_distance(a, b)))
    cylinder.firstMaterial?.diffuse.contents = UIColor.white
    let node = SCNNode(geometry: cylinder)
    node.simdPosition = (a + b) / 2
    // A cylinder's axis is local +Y, so aim +Y at the target.
    node.look(
      at: SCNVector3(b.x, b.y, b.z), up: sceneView.scene.rootNode.worldUp,
      localFront: SCNVector3(0, 1, 0))
    return node
  }

  // MARK: - Per-frame raycast

  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    // Throttle to ~15 Hz; Dart only needs smooth-looking numbers.
    guard time - lastEmit > 0.066 else { return }
    lastEmit = time
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      let center = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
      if let query = self.sceneView.raycastQuery(
        from: center, allowing: .estimatedPlane, alignment: .any),
        let hit = self.sceneView.session.raycast(query).first
      {
        let t = hit.worldTransform.columns.3
        self.currentHit = SIMD3<Float>(t.x, t.y, t.z)
      } else {
        self.currentHit = nil
      }
      self.emit()
    }
  }

  // MARK: - Stream to Dart

  private func emit(message: String? = nil) {
    var live: Double?
    if let hit = currentHit, let last = points.last {
      live = Double(simd_distance(last, hit))
    }
    var payload: [String: Any] = [
      "points": points.map { [Double($0.x), Double($0.y), Double($0.z)] },
      "tracking": currentHit != nil,
      "lidar": ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh),
    ]
    if let live = live { payload["live"] = live }
    if let message = message { payload["message"] = message }
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
