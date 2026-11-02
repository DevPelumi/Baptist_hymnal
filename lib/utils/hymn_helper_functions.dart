import '../models/hymn_data.dart';

class HymnHelperFunctions {
  /// log N search where n is list.length
  static HymnData? binSearch(List<HymnData> list, int id) {
    return _binSearch(list, id, 0, list.length - 1);
  }

  static HymnData? _binSearch(List<HymnData> list, int id, int start, int end) {
    while (start <= end) {
      int middle = (start + end) ~/ 2;
      if (id < list[middle].id) {
        return _binSearch(list, id, start, middle - 1);
      } else if (id > list[middle].id) {
        return _binSearch(list, id, middle + 1, end);
      } else {
        return list[middle];
      }
    }
    return null;
  }

  /// Hymns matching [query], best first.
  ///
  /// A number finds that hymn, then the hymns whose number starts with it, so
  /// typing 1, 5, 4 narrows to 154. Words find titles first, then lyrics.
  static List<HymnData> search(List<HymnData> hymns, String query) {
    final q = _normalise(query.trim());
    if (q.isEmpty) return hymns;

    if (int.tryParse(q) case final number?) {
      return [
        ...hymns.where((h) => h.id == number),
        ...hymns.where((h) => h.id != number && '${h.id}'.startsWith(q)),
      ];
    }

    final inTitle = <HymnData>[];
    final inWords = <HymnData>[];
    for (final hymn in hymns) {
      final title = _normalise(hymn.title);
      if (title.contains(q) || q.contains(title)) {
        inTitle.add(hymn);
      } else if (_lyrics(hymn).contains(q)) {
        inWords.add(hymn);
      }
    }
    return [...inTitle, ...inWords];
  }

  // Lower-cased once per hymn: searching re-reads them on every keystroke.
  static final Expando<String> _lyricsCache = Expando();

  static String _lyrics(HymnData hymn) =>
      _lyricsCache[hymn] ??= _normalise(hymn.contents.join(' '));

  /// Lower case, with curly apostrophes and line breaks made plain, so what
  /// people type matches how the books are written.
  static String _normalise(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[‘’`]'), "'")
      .replaceAll(RegExp(r'\s+'), ' ');
}
