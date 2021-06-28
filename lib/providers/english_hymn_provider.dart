import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../repositories/hymn_repository.dart';
import 'hymn_provider.dart';

class EnglishHymnProvider extends ChangeNotifier implements IHymnProvider {
  HymnRepository repo;

  Set<int> _isEnglishFavorites;

  EnglishHymnProvider() {
    repo = HymnRepository("English_Hymn");
    _isEnglishFavorites = {};
    fetchFavorites();
  }

  @override
  bool isFavorite(int id) => _isEnglishFavorites.contains(id);

  @override
  List<int> get favoritesKeys => _isEnglishFavorites.toList();

  @override
  Future<void> fetchFavorites() async {
    List<int> result = await repo.fetchFavoriteHymns();
    if (result != null) {
      _isEnglishFavorites.clear();
      _isEnglishFavorites.addAll(result);
    }
    notifyListeners();
  }

  @override
  Future<void> updateHymnFavorites(List<int> favorites) async {
    await repo.updateFavorites(favoritesKeys);
  }

  @override
  Future<void> toggleFavoriteForHymn(int hymnId) async {
    if (isFavorite(hymnId))
      _isEnglishFavorites.remove(hymnId);
    else
      _isEnglishFavorites.add(hymnId);
    notifyListeners();
    await updateHymnFavorites(favoritesKeys);
  }
}
