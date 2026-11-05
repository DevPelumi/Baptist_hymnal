import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
}) => PlatformInfo.isIOS ? cupertino : material;

/// The tint: system green on iOS, the brand green elsewhere.
Color accentColor(BuildContext context) => PlatformInfo.isIOS
    ? CupertinoColors.systemGreen.resolveFrom(context)
    : brandGreen;

Color labelColor(BuildContext context) => PlatformInfo.isIOS
    ? CupertinoColors.label.resolveFrom(context)
    : Theme.of(context).colorScheme.onSurface;

Color secondaryLabelColor(BuildContext context) => PlatformInfo.isIOS
    ? CupertinoColors.secondaryLabel.resolveFrom(context)
    : Theme.of(context).colorScheme.onSurfaceVariant;
