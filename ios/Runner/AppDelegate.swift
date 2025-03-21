import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let googleMapsAPIKey = Bundle.main.object(forInfoDictionaryKey: "GMapApiKey") as? String {
      GMSServices.provideAPIKey(googleMapsAPIKey)
    } else {
      fatalError("Google Maps API key not found")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
