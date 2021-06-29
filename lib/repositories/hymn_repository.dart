import 'package:shared_preferences/shared_preferences.dart';

class HymnRepository {
  final String _key;
  SharedPreferences _preferences;

  /// This class must be instantiated with a KEY indicating
  /// the local storage location of the class data to be used
  HymnRepository(String key) : this._key = key;

  Future<List<int>> fetchFavoriteHymns() async {
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
    // check if we have a data
    // if yes -> return this data
    if (_preferences.containsKey(_key)) {
      return _preferences
          .getStringList(_key)
          .map<int>((s) => int.parse(s))
          .toList();
    } else {
      // if no -> return null
      return null;
    }
  }

  /// stores this list of keys in the "key" position in storage
  Future<void> updateFavorites(List<int> favorites) async {
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
    await _preferences.setStringList(
        _key, favorites.map((b) => b.toString()).toList());
  }
}
