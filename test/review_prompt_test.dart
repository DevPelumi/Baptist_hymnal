import 'package:baptist_hymnal/utils/review_prompt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.britannio.in_app_review');
  late List<String> calls;
  late bool available;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls = [];
    available = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return call.method == 'isAvailable' ? available : null;
        });
    // Firebase isn't set up in tests, so the analytics event fails and logs.
    debugPrint = (message, {wrapWidth}) {};
  });

  tearDown(() => debugPrint = debugPrintThrottled);

  Future<void> readHymns(int count) async {
    for (var i = 0; i < count; i++) {
      await ReviewPrompt.onHymnOpened();
      await ReviewPrompt.onHymnClosed();
    }
  }

  int reviewRequests() => calls.where((c) => c == 'requestReview').length;

  test('asks when the fifth hymn is closed', () async {
    await readHymns(4);
    expect(reviewRequests(), 0);

    await readHymns(1);
    expect(reviewRequests(), 1);
  });

  test('hymns opened with the arrows count too', () async {
    for (var i = 0; i < 5; i++) {
      await ReviewPrompt.onHymnOpened();
    }
    await ReviewPrompt.onHymnClosed();
    expect(reviewRequests(), 1);
  });

  test('asks only once', () async {
    await readHymns(20);
    expect(reviewRequests(), 1);
  });

  test('tries again later if reviews are unavailable', () async {
    available = false;
    await readHymns(6);
    expect(reviewRequests(), 0);

    available = true;
    await readHymns(1);
    expect(reviewRequests(), 1);
  });
}
