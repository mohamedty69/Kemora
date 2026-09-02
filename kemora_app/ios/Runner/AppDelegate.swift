import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps iOS SDK key. Reuses the backend "Google:ApiKey".
    // Requires "Maps SDK for iOS" enabled in Google Cloud Console.
    GMSServices.provideAPIKey("AIzaSyAB_PVxiwsHPtMAkAmRKlm_TjMds3IgHAo")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
