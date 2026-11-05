import 'package:flutter/widgets.dart';

/// The app's typeface, used for all text Flutter draws. iOS draws its own
/// navigation and tab bars, alerts, switches and segmented controls, in the
/// system font.
const String appFont = 'Alata';

/// Adds [appFont] to the surrounding text style. For widgets that set their
/// own text style without a font, which drops back to the system font.
const TextStyle appFontStyle = TextStyle(fontFamily: appFont);

/// Puts [appFont] back on everything below. On iOS, adaptive_platform_ui's
/// AdaptiveScaffold gives each page a text style with no font, which drops
/// back to the system font, so each page's body goes inside one of these.
class AppFont extends StatelessWidget {
  const AppFont({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      DefaultTextStyle.merge(style: appFontStyle, child: child);
}

/// For hymn numbers and times, which Alata makes hard to read: its 1 is a
/// plain stroke, like a capital I. San Francisco on iOS; elsewhere the
/// family isn't found and the system font, Roboto, is used.
const String numberFont = 'CupertinoSystemText';
