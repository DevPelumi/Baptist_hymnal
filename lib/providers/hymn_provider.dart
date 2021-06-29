import 'package:flutter/material.dart';

import '../models/hymn_data.dart';
import '../repositories/hymn_repository.dart';

abstract class IHymnProvider extends ChangeNotifier {
  final HymnRepository repo;
  
  /// set of provider keys
  Set<int> _favorites;
  
  /// To be overriden, stores pointer to the datasource for this
  /// provider
  List<HymnData> get dataSource;

  /// IHymnProvider abstract class must be initialised 
  /// with a HymnRepository instance 
  /// that will communicate with the local storage 
  /// to fetch and update user's favorites
  IHymnProvider(this.repo) {
    if (this._favorites == null) fetchFavorites();
  }

  /// returns true if item is in the English hymn and was liked
  bool isFavorite(int hymnId) => _favorites.contains(hymnId);

  /// returns the list of keys of english liked hymns
  List<int> get favoritesKeys => _favorites.toList();

  /// add/remove from favorites list
  Future<void> toggleFavoriteForHymn(int hymnId) async {
    if (isFavorite(hymnId))
      _favorites.remove(hymnId);
    else
      _favorites.add(hymnId);
    notifyListeners();
    await updateHymnFavorites(favoritesKeys);
  }

  /// Function that fetches all hymns
  /// from the local storage/ persistence solution
  Future<void> fetchFavorites() async {
    _favorites = {};
    List<int> result = await repo.fetchFavoriteHymns();
    if (result != null) {
      _favorites.addAll(result);
    }
    notifyListeners();
  }

  /// updates the english favorites to the local storage
  Future<void> updateHymnFavorites(List<int> favorites) async {
    await repo.updateFavorites(favoritesKeys);
  }
}
