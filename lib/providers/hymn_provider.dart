import 'package:baptist_hymnal/List/english_hymn_list.dart';
import 'package:baptist_hymnal/repositories/hymn_repository.dart';
import 'package:flutter/foundation.dart';

class HymnProvider extends ChangeNotifier {
  HymnRepository repo;
  List<bool> _isEnglishFavorites;
  HymnProvider() {
    repo = HymnRepository();
  }
  List<bool> get isEnglishFavorites => [..._isEnglishFavorites];

  List<int> get englishFavoritesKey {
    List<int> ans = [];
    for (var i = 0; i < _isEnglishFavorites.length; i++) {
      if (_isEnglishFavorites[i]) ans.add(i);
    }
    return ans;
  }

  Future<void> fetchFavorites() async {
    List<bool> result = await repo.fetchFavoriteHymns();
    if (result == null) {
      // no data has been stored.. initialise all to false
      _isEnglishFavorites = List.generate(englishHymnData.length, (x) => false);
      updateFavorites(_isEnglishFavorites);
    } else {
      // return the stored data
      _isEnglishFavorites = result;
    }
  }

  Future<void> updateFavorites(List<bool> favorites) async {
    await repo.updateFavorites(_isEnglishFavorites);
  }

  void toggleFavoriteAtIndex(int i) {
    _isEnglishFavorites[i] = !_isEnglishFavorites[i];
    notifyListeners();
  }
}
