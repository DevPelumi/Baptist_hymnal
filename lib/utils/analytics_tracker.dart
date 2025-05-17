import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsTracker {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Screen tracking
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Hymn related events
  static Future<void> logHymnView({
    required int hymnId,
    required String hymnTitle,
    required String hymnType, // 'english', 'yoruba', or 'responsive'
  }) async {
    await _analytics.logEvent(
      name: 'hymn_viewed',
      parameters: {
        'hymn_id': hymnId,
        'hymn_title': hymnTitle,
        'hymn_type': hymnType,
      },
    );
  }

  static Future<void> logHymnFavorite({
    required int hymnId,
    required String hymnTitle,
    required bool isFavorite,
  }) async {
    await _analytics.logEvent(
      name: 'hymn_favorite_toggled',
      parameters: {
        'hymn_id': hymnId,
        'hymn_title': hymnTitle,
        'is_favorite': isFavorite,
      },
    );
  }

  static Future<void> logHymnShare({
    required int hymnId,
    required String hymnTitle,
  }) async {
    await _analytics.logEvent(
      name: 'hymn_shared',
      parameters: {
        'hymn_id': hymnId,
        'hymn_title': hymnTitle,
      },
    );
  }

  // Search events
  static Future<void> logSearch({
    required String searchTerm,
    required String searchType, // 'english', 'yoruba', or 'responsive'
    required int resultCount,
  }) async {
    await _analytics.logEvent(
      name: 'search_performed',
      parameters: {
        'search_term': searchTerm,
        'search_type': searchType,
        'result_count': resultCount,
      },
    );
  }

  // Settings events
  static Future<void> logFontSizeChange({
    required int oldSize,
    required int newSize,
  }) async {
    await _analytics.logEvent(
      name: 'font_size_changed',
      parameters: {
        'old_size': oldSize,
        'new_size': newSize,
      },
    );
  }

  static Future<void> logThemeChange({
    required String themeMode, // 'light', 'dark', or 'system'
  }) async {
    await _analytics.logEvent(
      name: 'theme_changed',
      parameters: {
        'theme_mode': themeMode,
      },
    );
  }

  // Ad events
  static Future<void> logAdImpression({
    required String adType, // 'banner' or 'interstitial'
    required String adUnitId,
  }) async {
    await _analytics.logEvent(
      name: 'ad_impression',
      parameters: {
        'ad_type': adType,
        'ad_unit_id': adUnitId,
      },
    );
  }

  static Future<void> logAdClick({
    required String adType,
    required String adUnitId,
  }) async {
    await _analytics.logEvent(
      name: 'ad_click',
      parameters: {
        'ad_type': adType,
        'ad_unit_id': adUnitId,
      },
    );
  }

  // Navigation events
  static Future<void> logNavigation({
    required String fromScreen,
    required String toScreen,
  }) async {
    await _analytics.logEvent(
      name: 'navigation',
      parameters: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
      },
    );
  }
}
