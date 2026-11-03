import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
// DuoPoseScope isn't exported. It says whether iPhone Duo's side strip is in
// use, which this workaround needs; drop it when the package fixes the bug.
// ignore: implementation_imports
import 'package:adaptive_platform_ui/src/toolbar/duo_vertical_bar.dart'
    show DuoPoseScope;
import 'package:flutter/widgets.dart';

/// On iPhone Duo, hands the app's tab bar to the tab page on screen, so the
/// tabs appear in the Duo's side strip.
///
/// adaptive_platform_ui 1.0.2 looks for the strip's tab bar on the page's own
/// scaffold or around its navigator, never on a scaffold wrapping the page in
/// the same route, which is where the home page keeps it. Without this the
/// strip shows no tabs, on the cover display and the inner one in landscape.
/// Everywhere else the tab bar stays on the home page, so the native tab bar
/// isn't rebuilt on every tab switch.
class DuoTabBar extends InheritedWidget {
  const DuoTabBar({super.key, required this.tabBar, required super.child});

  /// The tab bar for the page's scaffold, or null where the home page keeps it.
  final AdaptiveBottomNavigationBar? tabBar;

  /// Whether [context] is laid out around iPhone Duo's side strip.
  static bool inSideStrip(BuildContext context) =>
      PlatformInfo.isIOS && DuoPoseScope.of(context) != null;

  /// How far to move fixed controls at the top of a page down on iPhone Duo.
  /// The title band there fades out over 24pt below the inset the scaffold
  /// adds for it; scrolling content may pass under the fade, but a search
  /// field or segmented control left in it looks washed out.
  static double titleFadeClearance(BuildContext context) =>
      inSideStrip(context) ? 24 : 0;

  /// Room to leave on iPhone Duo for the side strip in something drawn over
  /// the page, such as a sheet: the strip's buttons stay on top of it.
  static EdgeInsets stripInsets(BuildContext context) {
    final pose = PlatformInfo.isIOS ? DuoPoseScope.of(context) : null;
    if (pose == null) return EdgeInsets.zero;
    return pose.onLeft
        ? EdgeInsets.only(left: pose.bandWidth)
        : EdgeInsets.only(right: pose.bandWidth);
  }

  /// The tab bar a tab page should give its scaffold.
  static AdaptiveBottomNavigationBar? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DuoTabBar>()?.tabBar;

  @override
  bool updateShouldNotify(DuoTabBar oldWidget) => tabBar != oldWidget.tabBar;
}
