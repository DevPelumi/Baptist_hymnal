import 'package:baptist_hymnal/data/english_hymns.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English hymn ids are unique and in order', () {
    final ids = englishHymnData.map((h) => h.id).toList();
    // Favourites look hymns up by binary search on id.
    expect(ids, orderedEquals([...ids]..sort()));
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('the Amens 543-554 are their own hymns', () {
    final byId = {for (final h in englishHymnData) h.id: h};
    expect(byId[542]!.contents, hasLength(1));
    for (var id = 543; id <= 554; id++) {
      expect(byId[id]?.title, endsWith('Amen'), reason: 'hymn $id');
    }
  });
}
