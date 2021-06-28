import 'package:baptist_hymnal/data/english_hymns.dart';
import 'package:baptist_hymnal/models/hymn_data.dart';
import 'package:baptist_hymnal/utils/hymn_helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

void main() {
  group('Testing the binarySearch function of the hymnHelperFunctions', () {
    test('should return data if the item to be gotten is the last item', () {
      // arrange
      HymnData x = englishHymnData[englishHymnData.length - 1];
      // act
      HymnData y = HymnHelperFunctions.binSearch(englishHymnData, x.id);

      // assert
      expect(y, x);
    });
    test('should return data if the item to be gotten is the first item', () {
      // arrange
      HymnData x = englishHymnData[0];
      // act
      HymnData y = HymnHelperFunctions.binSearch(englishHymnData, x.id);
      // assert
      expect(y, x);
    });
    test('should return data somewhere random', () {
      // arrange
      int rand = Random().nextInt(englishHymnData.length - 1);
      HymnData x = englishHymnData[rand];
      // act
      HymnData y = HymnHelperFunctions.binSearch(englishHymnData, x.id);
      // assert
      expect(y, x);
    });
  });
}
