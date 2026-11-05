import 'package:baptist_hymnal/purchases/upgrade_prompt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    UpgradePrompt.isDue.value = false;
    // Firebase isn't set up in tests, so the analytics event fails and logs.
    debugPrint = (message, {wrapWidth}) {};
  });

  tearDown(() => debugPrint = debugPrintThrottled);

  Future<bool> dueWith(Map<String, Object> saved) async {
    SharedPreferences.setMockInitialValues(saved);
    await UpgradePrompt.refresh();
    return UpgradePrompt.isDue.value;
  }

  test('waits until the user has opened three hymns', () async {
    expect(await dueWith({}), isFalse);
    expect(await dueWith({'review/hymnsOpened': 2}), isFalse);
    expect(await dueWith({'review/hymnsOpened': 3}), isTrue);
  });

  test('counts people already asked for a review as engaged', () async {
    expect(await dueWith({'review/asked': true}), isTrue);
  });

  test('stays away for two weeks after Not Now', () async {
    expect(await dueWith({'review/hymnsOpened': 5}), isTrue);
    await UpgradePrompt.dismiss();
    expect(UpgradePrompt.isDue.value, isFalse);
    await UpgradePrompt.refresh();
    expect(UpgradePrompt.isDue.value, isFalse);

    final fifteenDaysAgo = DateTime.now()
        .subtract(const Duration(days: 15))
        .millisecondsSinceEpoch;
    expect(
      await dueWith({
        'review/hymnsOpened': 5,
        'upgradePrompt/dismissedAt': fifteenDaysAgo,
      }),
      isTrue,
    );
  });
}
