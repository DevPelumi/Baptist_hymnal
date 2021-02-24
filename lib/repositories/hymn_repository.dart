import 'package:shared_preferences/shared_preferences.dart';

const FAVORITES = 'favorites';

class HymnRepository {
  SharedPreferences _preferences;
  Future<List<bool>> fetchFavoriteHymns() async {
    _preferences = await SharedPreferences.getInstance();
    // check if we have a data
    // if yes -> return this data
    if (_preferences.containsKey(FAVORITES)) {
      return _preferences
          .getStringList(FAVORITES)
          .map<bool>((s) => s == "1" ? true : false)
          .toList();
    } else {
      // if no -> return null
      return null;
    }
  }

  /// "1" is true and "0" is false
  Future<void> updateFavorites(List<bool> favorites) async {
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
    _preferences.setStringList(
        FAVORITES, favorites.map((b) => b ? "1" : "0").toList());
  }
}
