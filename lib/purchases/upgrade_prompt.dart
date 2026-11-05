import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/analytics_tracker.dart';
import '../utils/review_prompt.dart';

/// When Home offers Premium: once someone has opened [hymnsBeforeShowing]
/// hymns, so they know the app before being asked, and not again for
/// [snooze] after they choose Not Now.
class UpgradePrompt {
  UpgradePrompt._();

  static const int hymnsBeforeShowing = 3;
  static const Duration snooze = Duration(days: 14);

  static const String _dismissedAtKey = 'upgradePrompt/dismissedAt';

  /// Whether Home should offer Premium, leaving aside whether there's
  /// anything to sell or it's already bought.
  static final ValueNotifier<bool> isDue = ValueNotifier(false);

  /// Call at launch, after [ReviewPrompt.initialize], and when a hymn closes.
  static Future<void> refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedAt = prefs.getInt(_dismissedAtKey);
      final snoozed =
          dismissedAt != null &&
          DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(dismissedAt),
              ) <
              snooze;
      isDue.value =
          !snoozed && await ReviewPrompt.hasOpenedAtLeast(hymnsBeforeShowing);
    } catch (e) {
      debugPrint('Checking the upgrade prompt failed: $e');
    }
  }

  /// Not Now: hides the prompt for [snooze].
  static Future<void> dismiss() async {
    isDue.value = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _dismissedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      await AnalyticsTracker.logUpgradePromptDismissed();
    } catch (e) {
      debugPrint('Saving the upgrade prompt dismissal failed: $e');
    }
  }
}
