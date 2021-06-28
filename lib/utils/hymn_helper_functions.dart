import '../models/hymn_data.dart';

class HymnHelperFunctions {
  static HymnData binSearch(List<HymnData> list, int id) {
    return _binSearch(list, id, 0, list.length - 1);
  }

  static HymnData _binSearch(List<HymnData> list, int id, int start, int end) {
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
}
