import 'package:baptist_hymnal/utils/hymn_helper_functions.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/english_hymns.dart';
import '../data/responsive_reading.dart';
import '../data/yoruba_hymns.dart';
import '../models/hymn_data.dart';
import '../providers/english_hymn_provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/responsive_reading_provider.dart';
import '../widgets/hymn_tile.dart';

class SearchScreen extends StatefulWidget {
  final int initialTabIndex;
  SearchScreen({this.initialTabIndex = 0});
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  List<HymnData> _data;
  SearchBarController<HymnData> _searchBarController;
  TabController _tabController;
  IHymnProvider _provider;
  bool _ascending = true;
  bool _favorites = true;
  void _getData(BuildContext context) {
    switch (_tabController.index) {
      case 1:
        _data = yorubaHymnData;
        break;
      case 2:
        _data = responsive;
        _provider = context.read<ResponsiveReadingProvider>();
        break;
      default:
        _data = englishHymnData;
        _provider = context.read<EnglishHymnProvider>();

        break;
    }
    _searchBarController.replayLastSearch();
    setState(() {});
  }

  @override
  void initState() {
    _searchBarController = new SearchBarController();
    _tabController = TabController(
        initialIndex: widget.initialTabIndex, length: 3, vsync: this)
      ..addListener(() {
        _getData(context);
      });
    _getData(context);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<HymnData>> _filterHymns(String searchString) async {
    searchString = searchString?.trim();
    if (searchString == null || searchString.isEmpty) {
      return _data;
    } else {
      return _data
          .where((hymn) =>
              hymn.id.toString() == searchString ||
              hymn.title.toLowerCase().contains(searchString.toLowerCase()) ||
              searchString.toLowerCase().contains(hymn.title.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SearchBar<HymnData>(
            textStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Holy, Holy, Holy',
            emptyWidget: Center(child: Text('Search by hymn title or hymn number')),
            header: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).accentColor,
                  tabs: [
                    Tab(text: 'English Hymns'),
                    Tab(text: 'Yoruba Hymns'),
                    Tab(text: 'Reading'),
                  ],
                ),
                Row(
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
                          SizedBox(width: 5),
                          AnimatedContainer(
                              curve: Curves.bounceInOut,
                              duration: Duration(milliseconds: 300),
                              child: _ascending
                                  ? Icon(Icons.arrow_upward, size: 16)
                                  : Icon(Icons.arrow_downward, size: 16))
                        ])),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _favorites = !_favorites;
                            _ascending = true;
                          });
                          _searchBarController.sortList((a, b) =>
                              (_provider.isFavorite(a.id)
                                  ? -1
                                  : _provider.isFavorite(b.id)
                                      ? 1
                                      : 0) *
                              (_favorites ? 1 : -1));
                        },
                        child: Flex(direction: Axis.horizontal, children: [
                          Text('Favorites'),
                          SizedBox(width: 5),
                          AnimatedContainer(
                              curve: Curves.bounceInOut,
                              duration: Duration(milliseconds: 300),
                              child: _favorites
                                  ? Icon(Icons.arrow_upward, size: 16)
                                  : Icon(Icons.arrow_downward, size: 16))
                        ]))
                  ],
                ),
              ],
            ),
            searchBarController: _searchBarController,
            debounceDuration: const Duration(milliseconds: 200),
            loader: const CircularProgressIndicator(),
            minimumChars: 0,
            onSearch: _filterHymns,
            onItemFound: (HymnData list, int index) {
              final x = HymnTile(list, _provider, showFavorites: false);
              if (_provider.isFavorite(list.id)) {
                return Stack(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  children: [
                    x,
                    Positioned(
                        right: 5,
                        top: 3,
                        child: Icon(
                          Icons.bookmark,
                          color: Colors.red,
                          size: 15,
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
