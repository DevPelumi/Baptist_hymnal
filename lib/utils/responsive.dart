import 'package:flutter/widgets.dart';

/// Layout sizes shared by the screens, so they read well on phones, tablets
/// and foldables alike.
class Responsive {
  /// The widest a column of text or list rows gets, like iOS's readable
  /// content width: longer lines are hard to follow.
  static const double readableWidth = 720;

  /// Extra side space that centres a [readableWidth] column in the window.
  /// Zero on a phone.
  static double inset(BuildContext context) =>
      ((MediaQuery.sizeOf(context).width - readableWidth) / 2).clamp(
        0.0,
        double.infinity,
      );

  /// How many book cards fit side by side on the home screen.
  static int columns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}
