import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_tracker.dart';

/// Asks for an App Store or Google Play review once the user has opened
/// [hymnsOpenedBeforeAsking] hymns, or one hymn if they used an older version.
class ReviewPrompt {
  static const int hymnsOpenedBeforeAsking = 5;

  /// "Baptist Hymnal - Complete". iOS needs it to open the review page.
  static const String appStoreId = '6443568995';

  static const String _hymnsOpenedKey = 'review/hymnsOpened';
  static const String _askedKey = 'review/asked';

  /// Call once at launch, before any hymn opens. People who used the app before
  /// this version have read plenty of hymns, so they're asked after their
  /// first. They can only be told apart from new users if they saved a
  /// favourite or changed a setting.
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_hymnsOpenedKey)) return;
    // Holds only this app's own saved data, which on the first launch of this
    // version can only come from an older one.
    final isExistingUser = prefs.getKeys().isNotEmpty;
    await prefs.setInt(
      _hymnsOpenedKey,
      isExistingUser ? hymnsOpenedBeforeAsking - 1 : 0,
    );
  }

  /// Call when a hymn page opens, including from the next and previous arrows.
  static Future<void> onHymnOpened() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await prefs.setInt(
      _hymnsOpenedKey,
      (prefs.getInt(_hymnsOpenedKey) ?? 0) + 1,
    );
  }

  /// Call when the user leaves a hymn page and no full-screen ad is showing.
  /// Asks once, so the prompt never shows on top of the lyrics. iOS and
  /// Android decide whether the review sheet actually appears.
  static Future<void> onHymnClosed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_askedKey) ?? false) return;
      final hymnsOpened = prefs.getInt(_hymnsOpenedKey) ?? 0;
      if (hymnsOpened < hymnsOpenedBeforeAsking) return;

      // False without the Play Store, so later closes try again.
      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;

      await prefs.setBool(_askedKey, true);
      await review.requestReview();
      await AnalyticsTracker.logReviewRequested(source: 'prompt');
    } catch (e) {
      debugPrint('Review prompt failed: $e');
    }
  }

  /// Opens the app's store page, on the review form on iOS. For buttons, where
  /// the in-app sheet might not appear.
  static Future<void> openStorePage() async {
    try {
      await InAppReview.instance.openStoreListing(appStoreId: appStoreId);
      await AnalyticsTracker.logReviewRequested(source: 'settings');
    } catch (e) {
      debugPrint('Opening the store page failed: $e');
    }
  }
}
