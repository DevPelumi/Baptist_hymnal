import 'package:baptist_hymnal/List/english_hymn_list.dart';
import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/widgets/hymn_tile.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HomeSearch extends StatefulWidget {
  @override
  _HomeSearchState createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  SearchBarController<EnglishHymnList> _searchBarController;
  bool _ascending = true;
  bool _favorites = true;

  @override
  void initState() {
    _searchBarController = new SearchBarController();
    super.initState();
  }

  Future<List<EnglishHymnList>> _filterHymns(String searchString) async {
    searchString = searchString?.trim();
    if (searchString == null || searchString.isEmpty) {
      return [...englishHymnData];
    } else {
      return englishHymnData
          .where((hymn) =>
              hymn.hymnNumber.toString() == searchString ||
              hymn.hymnTitle
                  .toLowerCase()
                  .contains(searchString.toLowerCase()) ||
              searchString.toLowerCase().contains(hymn.hymnTitle.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HymnProvider>();
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SearchBar<EnglishHymnList>(
            emptyWidget: Center(child: Text('Enter search text!')),
            header: Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _ascending = !_ascending;
                        _favorites = false;
                      });
                      _searchBarController.sortList((a, b) =>
                          (a.hymnNumber - b.hymnNumber) *
                          (_ascending ? 1 : -1));
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
                          (provider.isEnglishFavorites[a.hymnNumber - 1]
                              ? -1
                              : provider.isEnglishFavorites[b.hymnNumber - 1]
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
            onItemFound: (EnglishHymnList list, int index) {
              final x =
                  HymnTile(list.hymnNumber, provider, showFavorites: false);
              if (provider.isEnglishFavorites[list.hymnNumber - 1]) {
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
