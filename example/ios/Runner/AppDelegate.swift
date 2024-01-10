import UIKit
import Flutter
import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        registerAdFactory()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func registerAdFactory() {
        let nativeAdFactory = NativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "Native_Common", nativeAdFactory: nativeAdFactory)

        let inlineAdFactory = InlineAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "Native_Small", nativeAdFactory: inlineAdFactory)
    }
}
