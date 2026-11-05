import CoreText
import Flutter
import ObjectiveC
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets flutter_local_notifications show the hymn of the day while the
    // app is open, and hear when one is tapped.
    UNUserNotificationCenter.current().delegate = self
    useAppFontInNativeBars()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// UIKit draws the tab bar and the title bars itself, so the app's font,
  /// Alata, never reaches them from Flutter. Loads Alata from the Flutter
  /// assets and gives it to both. Only the font changes: adaptive_platform_ui
  /// still sets the colours and backgrounds.
  private func useAppFontInNativeBars() {
    let key = FlutterDartProject.lookupKey(forAsset: "assets/fonts/Alata-Regular.ttf")
    guard let path = Bundle.main.path(forResource: key, ofType: nil) else { return }
    CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: path) as CFURL, .process, nil)
    guard let tabFont = UIFont(name: "Alata-Regular", size: 10),
      let titleFont = UIFont(name: "Alata-Regular", size: 17),
      let largeTitleFont = UIFont(name: "Alata-Regular", size: 34)
    else { return }

    // iOS 26's Liquid Glass tab bar reads fonts only from a UITabBarAppearance.
    let tabs = UITabBarAppearance()
    tabs.configureWithTransparentBackground()
    for layout in [
      tabs.stackedLayoutAppearance,
      tabs.inlineLayoutAppearance,
      tabs.compactInlineLayoutAppearance,
    ] {
      layout.normal.titleTextAttributes = [.font: tabFont]
      layout.selected.titleTextAttributes = [.font: tabFont]
    }
    UITabBar.appearance().standardAppearance = tabs
    UITabBar.appearance().scrollEdgeAppearance = tabs

    TitleBarFont.install(title: titleFont, largeTitle: largeTitleFont)
  }
}

/// adaptive_platform_ui gives each title bar its own UINavigationBarAppearance,
/// which an appearance proxy can't reach. So when any appearance is set on a
/// title bar, this adds Alata to it first.
private enum TitleBarFont {
  static var title: [NSAttributedString.Key: Any] = [:]
  static var largeTitle: [NSAttributedString.Key: Any] = [:]

  static func install(title titleFont: UIFont, largeTitle largeTitleFont: UIFont) {
    // Alata has one weight. A thin outline in the text's own colour stands in
    // for the semibold system title.
    title = [.font: titleFont, .strokeWidth: -3.0]
    largeTitle = [.font: largeTitleFont, .strokeWidth: -3.0]
    swap(
      #selector(setter: UINavigationBar.standardAppearance),
      #selector(UINavigationBar.appFont_setStandardAppearance(_:)))
    swap(
      #selector(setter: UINavigationBar.scrollEdgeAppearance),
      #selector(UINavigationBar.appFont_setScrollEdgeAppearance(_:)))
    swap(
      #selector(setter: UINavigationBar.compactAppearance),
      #selector(UINavigationBar.appFont_setCompactAppearance(_:)))
  }

  static func withAppFont(_ appearance: UINavigationBarAppearance) -> UINavigationBarAppearance {
    appearance.titleTextAttributes.merge(title) { _, new in new }
    appearance.largeTitleTextAttributes.merge(largeTitle) { _, new in new }
    return appearance
  }

  private static func swap(_ original: Selector, _ replacement: Selector) {
    guard let originalMethod = class_getInstanceMethod(UINavigationBar.self, original),
      let replacementMethod = class_getInstanceMethod(UINavigationBar.self, replacement)
    else { return }
    method_exchangeImplementations(originalMethod, replacementMethod)
  }
}

extension UINavigationBar {
  // After the swap, each of these names the original setter.
  @objc fileprivate func appFont_setStandardAppearance(_ appearance: UINavigationBarAppearance) {
    appFont_setStandardAppearance(TitleBarFont.withAppFont(appearance))
  }

  @objc fileprivate func appFont_setScrollEdgeAppearance(_ appearance: UINavigationBarAppearance?) {
    appFont_setScrollEdgeAppearance(appearance.map(TitleBarFont.withAppFont))
  }

  @objc fileprivate func appFont_setCompactAppearance(_ appearance: UINavigationBarAppearance?) {
    appFont_setCompactAppearance(appearance.map(TitleBarFont.withAppFont))
  }
}
