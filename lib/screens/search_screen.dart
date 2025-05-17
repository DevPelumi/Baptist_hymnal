import 'package:baptist_hymnal/providers/yoruba_hymn_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/hymn_data.dart';
import '../providers/english_hymn_provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/responsive_reading_provider.dart';
import '../widgets/hymn_list_item.dart';

class SearchScreen extends StatefulWidget {
  final int initialTabIndex;
  const SearchScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late List<HymnData> _displayedData;
  late TabController _tabController;
  late TextEditingController _textController;
  IHymnProvider? _provider;
  bool _ascending = true;
  bool _favorites = true;

  void _getData(BuildContext context) {
    if (!mounted) return;

    final _update = () {
      if (mounted) setState(() {});
    };

    _provider?.removeListener(_update);

    switch (_tabController.index) {
      case 1:
        _provider = context.read<YorubaHymnProvider>();
        break;
      case 2:
        _provider = context.read<ResponsiveReadingProvider>();
        break;
      default:
        _provider = context.read<EnglishHymnProvider>();
        break;
    }

    _provider?.addListener(_update);
    _displayedData = _filterHymns(_textController.text);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        initialIndex: widget.initialTabIndex, length: 3, vsync: this);
    _textController = TextEditingController();
    _displayedData = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getData(context);
    _tabController.addListener(() {
      if (mounted) _getData(context);
    });
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _displayedData = _filterHymns(_textController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _provider?.removeListener(() {});
    super.dispose();
  }

  List<HymnData> _filterHymns(String searchString) {
    if (_provider == null) return [];

    final trimmed = searchString.trim();
    if (trimmed.isEmpty) {
      return List.from(_provider!.dataSource);
    } else {
      return _provider!.dataSource
          .where((hymn) =>
              hymn.id.toString() == trimmed ||
              hymn.title.toLowerCase().contains(trimmed.toLowerCase()) ||
              trimmed.toLowerCase().contains(hymn.title.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: colorScheme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        title: CupertinoSearchTextField(
          controller: _textController,
          placeholder: 'Search hymns...',
          style: theme.textTheme.bodyLarge,
          placeholderStyle: theme.textTheme.bodyLarge?.copyWith(
            color: CupertinoColors.placeholderText.resolveFrom(context),
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5.resolveFrom(context),
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: CupertinoColors.activeGreen.resolveFrom(context),
              unselectedLabelColor:
                  CupertinoColors.systemGrey.resolveFrom(context),
              indicatorColor: CupertinoColors.activeGreen.resolveFrom(context),
              indicatorWeight: 2,
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleMedium,
              tabs: const [
                Tab(text: 'English'),
                Tab(text: 'Yoruba'),
                Tab(text: 'Reading'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _provider == null
                ? Center(
                    child: CupertinoActivityIndicator(
                      radius: 14,
                    ),
                  )
                : _displayedData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 64,
                              color: CupertinoColors.systemGrey
                                  .resolveFrom(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hymns found',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: CupertinoColors.systemGrey
                                    .resolveFrom(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try different keywords',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: CupertinoColors.systemGrey2
                                    .resolveFrom(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 8),
                        itemCount: _displayedData.length,
                        itemBuilder: (ctx, i) {
                          final hymn = _displayedData[i];
                          return HymnListItem(
                            hymn: hymn,
                            provider: _provider!,
                            showFavorite: false,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
