abstract class IHymnProvider {
  /// returns true if item is in the English hymn and was liked
  bool isFavorite(int hymnId);

  /// returns the list of keys of english liked hymns
  List<int> get favoritesKeys;

  /// add/remove from favorites list
  void toggleFavoriteForHymn(int id);

  /// Function that fetches all hymns
  /// from the local storage/ persistence solution
  Future<void> fetchFavorites();

  /// updates the english favorites to the local storage
  Future<void> updateHymnFavorites(List<int> favorites);
}