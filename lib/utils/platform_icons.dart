import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/widgets.dart';

/// Brand tint, close to iOS system green so native controls look at home.
const Color brandGreen = Color(0xFF34A853);

/// An icon for adaptive_platform_ui widgets that take either form: an SF
/// Symbol name on iOS 26+ (drawn by UIKit), otherwise an [IconData].
Object platformIcon({
  required String sfSymbol,
  required IconData cupertino,
  required IconData material,
}) {
  if (PlatformInfo.isIOS26OrHigher()) return sfSymbol;
  return platformIconData(cupertino: cupertino, material: material);
}

/// The Cupertino icon on iOS, the Material icon elsewhere.
IconData platformIconData({
  required IconData cupertino,
  required IconData material,
}) =>
    PlatformInfo.isIOS ? cupertino : material;
