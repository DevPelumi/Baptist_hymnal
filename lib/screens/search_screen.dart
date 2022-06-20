import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<HymnData> _displayedData;
  TabController _tabController;
  TextEditingController _textController;
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
    _displayedData = _filterHymns(_textController.text);
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(
        initialIndex: widget.initialTabIndex, length: 3, vsync: this)
      ..addListener(() {
        _getData(context);
      });
    _textController = TextEditingController();
    _getData(context);
    _textController.addListener(() {
      _displayedData = _filterHymns(_textController.text);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  List<HymnData> _filterHymns(String searchString) {
    searchString = searchString?.trim();
    if (searchString == null || searchString.isEmpty) {
      return List.from(_data);
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
    ThemeData appBarTheme(BuildContext context) {
      assert(context != null);
      final ThemeData theme = Theme.of(context);
      final ColorScheme colorScheme = theme.colorScheme;
      assert(theme != null);
      return theme.copyWith(
        appBarTheme: AppBarTheme(
          systemOverlayStyle: colorScheme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          backgroundColor: colorScheme.brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
          textTheme: theme.textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: theme.inputDecorationTheme.hintStyle,
          border: InputBorder.none,
        ),
      );
    }

    final tabBar = TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).accentColor,
      tabs: [
        Tab(text: 'English Hymns'),
        Tab(text: 'Yoruba Hymns'),
        Tab(text: 'Reading'),
      ],
    );
    return Theme(
        data: appBarTheme(context),
        child: Scaffold(
          appBar: AppBar(
              title: TextField(
                controller: _textController,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(hintText: 'Holy, Holy, Holy'),
              ),
              bottom: tabBar,
              actions: [
                IconButton(icon: Icon(Icons.search), onPressed: () {})
              ]),
          body: Column(
            children: [
              // Row(
              //   children: [
              //     TextButton(
              //         onPressed: () {
              //           setState(() {
              //             _ascending = !_ascending;
              //             _favorites = false;
              //           });
              //         },
              //         child: Flex(direction: Axis.horizontal, children: [
              //           Text('Hymn Number'),
              //           SizedBox(width: 5),
              //           AnimatedContainer(
              //               curve: Curves.bounceInOut,
              //               duration: Duration(milliseconds: 300),
              //               child: _ascending
              //                   ? Icon(Icons.arrow_upward, size: 16)
              //                   : Icon(Icons.arrow_downward, size: 16))
              //         ])),
              //     TextButton(
              //         onPressed: () {
              //           setState(() {
              //             _favorites = !_favorites;
              //             _ascending = true;
              //           });
              //         },
              //         child: Flex(direction: Axis.horizontal, children: [
              //           Text('Favorites'),
              //           SizedBox(width: 5),
              //           AnimatedContainer(
              //               curve: Curves.bounceInOut,
              //               duration: Duration(milliseconds: 300),
              //               child: _favorites
              //                   ? Icon(Icons.arrow_upward, size: 16)
              //                   : Icon(Icons.arrow_downward, size: 16))
              //         ]))
              //   ],
              // ),
              Expanded(
                child: _displayedData.length == 0
                    ? Container()
                    : ListView.builder(
                        itemCount: _displayedData.length,
                        itemBuilder: (ctx, i) {
                          final x = HymnTile(_displayedData[i], _provider,
                              showFavorites: false);
                          if (_provider.isFavorite(_displayedData[i].id)) {
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
            ],
          ),
        ));
  }
}
