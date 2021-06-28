import 'package:baptist_hymnal/data/english_hymns.dart';
import 'package:baptist_hymnal/models/hymn_data.dart';
import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/widgets/hymn_tile.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final List<HymnData> data;
  SearchScreen({List<HymnData> list})
      : this.data = list ?? [...englishHymnData];
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchBarController<HymnData> _searchBarController;
  bool _ascending = true;
  bool _favorites = true;

  @override
  void initState() {
    _searchBarController = new SearchBarController();
    super.initState();
  }

  Future<List<HymnData>> _filterHymns(String searchString) async {
    searchString = searchString?.trim();
    if (searchString == null || searchString.isEmpty) {
      return widget.data;
    } else {
      return widget.data
          .where((hymn) =>
              hymn.id.toString() == searchString ||
              hymn.title.toLowerCase().contains(searchString.toLowerCase()) ||
              searchString.toLowerCase().contains(hymn.title.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EnglishHymnProvider>();
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SearchBar<HymnData>(
            hintText: 'Holy, Holy, Holy',
            emptyWidget: Center(child: Text('Enter search text!')),
            header: Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _ascending = !_ascending;
                        _favorites = false;
                      });
                      _searchBarController.sortList(
                          (a, b) => (a.id - b.id) * (_ascending ? 1 : -1));
                    },
                    child: Flex(direction: Axis.horizontal, children: [
                      Text('Hymn Number'),
                      AnimatedContainer(
                          curve: Curves.bounceInOut,
                          duration: Duration(milliseconds: 300),
                          child: _ascending
                              ? Icon(Icons.arrow_upward)
                              : Icon(Icons.arrow_downward))
                    ])),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _favorites = !_favorites;
                        _ascending = true;
                      });
                      _searchBarController.sortList((a, b) =>
                          (provider.isFavorite(a.id)
                              ? -1
                              : provider.isFavorite(b.id)
                                  ? 1
                                  : 0) *
                          (_favorites ? 1 : -1));
                    },
                    child: Flex(direction: Axis.horizontal, children: [
                      Text('Favorites'),
                      AnimatedContainer(
                          curve: Curves.bounceInOut,
                          duration: Duration(milliseconds: 300),
                          child: _favorites
                              ? Icon(Icons.arrow_upward)
                              : Icon(Icons.arrow_downward))
                    ]))
              ],
            ),
            searchBarController: _searchBarController,
            debounceDuration: const Duration(milliseconds: 200),
            loader: const CircularProgressIndicator(),
            minimumChars: 0,
            onSearch: _filterHymns,
            onItemFound: (HymnData list, int index) {
              final x = HymnTile(list, provider, showFavorites: false);
              if (provider.isFavorite(list.id)) {
                return Stack(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  children: [
                    x,
                    Positioned(
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 30,
                          height: 50,
                          color: Colors.green.shade300,
                          child: Icon(Icons.star, color: Colors.white),
                        ))
                  ],
                );
              } else {
                return x;
              }
            }),
      ),
    ));
  }
}
