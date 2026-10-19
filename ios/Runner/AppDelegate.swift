import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ArMeasure") {
      registrar.register(
        ArMeasureFactory(messenger: registrar.messenger()),
        withId: "kaiyaletz/ar_measure_view")
    }

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "RoomScan") {
      RoomScanSupport.register(messenger: registrar.messenger())
      registrar.register(
        RoomScanFactory(messenger: registrar.messenger()),
        withId: "kaiyaletz/room_scan_view")
    }
  }
}
