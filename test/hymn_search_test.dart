import 'package:baptist_hymnal/models/hymn_data.dart';
import 'package:baptist_hymnal/utils/hymn_helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hymns = [
    HymnData(1, 'Holy, Holy, Holy', [
      '1. Holy, holy, holy! Lord God Almighty!',
    ]),
    HymnData(15, 'Come, Thou Almighty King', ['1. Come, Thou Almighty King,']),
    HymnData(150, 'Jesus Shall Reign', [
      '1. Jesus shall reign where’er the sun',
    ]),
    HymnData(154, 'Great Redeemer', ['1. Great Redeemer, we adore Thee']),
    HymnData(215, 'Amazing Grace', ['1. Amazing grace! how sweet the sound']),
  ];

  List<int> ids(String query) => [
    for (final h in HymnHelperFunctions.search(hymns, query)) h.id,
  ];

  test('an empty query lists every hymn', () {
    expect(ids('  '), [1, 15, 150, 154, 215]);
  });

  test('a number finds that hymn first, then numbers starting with it', () {
    expect(ids('15'), [15, 150, 154]);
    expect(ids('154'), [154]);
    expect(ids('1'), [1, 15, 150, 154]);
  });

  test('a number that is no hymn finds nothing', () {
    expect(ids('999'), isEmpty);
  });

  test('words find titles before lyrics', () {
    // "Almighty" is in 15's title and only in 1's words.
    expect(ids('almighty'), [15, 1]);
  });

  test('typed apostrophes match the books’ curly ones', () {
    expect(ids("where'er the sun"), [150]);
  });

  test('the opening line skips a first line that opens with the title', () {
    const hymn = HymnData(1, 'Holy, Holy, Holy', [
      '1. Holy, holy, holy! Lord God Almighty!\nEarly in the morning',
    ]);
    expect(HymnHelperFunctions.openingLine(hymn), 'Early in the morning');
    // With nothing else to show, the first line is better than nothing.
    expect(
      HymnHelperFunctions.openingLine(hymns.first),
      'Holy, holy, holy! Lord God Almighty!',
    );
    expect(
      HymnHelperFunctions.openingLine(hymns[1]),
      'Come, Thou Almighty King',
    );
  });
}
