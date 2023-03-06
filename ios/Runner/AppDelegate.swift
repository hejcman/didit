import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let cameraViewFactory = FLCameraViewFactory()

    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let cameraViewFactory = FLCameraViewFactory()
      self.registrar(forPlugin: "Runner")!.register(cameraViewFactory, withId: "plugins.diditapp/flutter_camera_view")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
