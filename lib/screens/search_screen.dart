import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:baptist_hymnal/providers/yoruba_hymn_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show GlassSwipeActionScope;
import 'package:provider/provider.dart';

import '../models/hymn_data.dart';
import '../providers/english_hymn_provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/responsive_reading_provider.dart';
import '../utils/hymn_helper_functions.dart';
import '../utils/responsive.dart';
import '../widgets/hymn_list_item.dart';

class SearchScreen extends StatefulWidget {
  final int initialTabIndex;
  const SearchScreen({super.key, this.initialTabIndex = 0});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  late int _book = widget.initialTabIndex;
  IHymnProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchProvider();
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  void _watchProvider() {
    final IHymnProvider next = switch (_book) {
      1 => context.read<YorubaHymnProvider>(),
      2 => context.read<ResponsiveReadingProvider>(),
      _ => context.read<EnglishHymnProvider>(),
    };
    if (identical(next, _provider)) return;
    _provider?.removeListener(_onProviderChanged);
    _provider = next..addListener(_onProviderChanged);
  }

  List<HymnData> _filterHymns(String searchString) {
    final provider = _provider;
    if (provider == null) return [];
    return HymnHelperFunctions.search(provider.dataSource, searchString);
  }

  Widget _buildSearchField() {
    void onChanged(String _) => setState(() {});
    if (PlatformInfo.isIOS) {
      return CupertinoSearchTextField(
        controller: _textController,
        placeholder: 'Number or title',
        onChanged: onChanged,
      );
    }
    return SearchBar(
      controller: _textController,
      hintText: 'Number or title',
      leading: const Icon(Icons.search),
      elevation: const WidgetStatePropertyAll(0),
      onChanged: onChanged,
      trailing: [
        if (_textController.text.isNotEmpty)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: () => setState(_textController.clear),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterHymns(_textController.text);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Search'),
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          // A centred column on a tablet, not the full width.
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.inset(context),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, insets.top + 8, 16, 0),
                  child: _buildSearchField(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: AdaptiveSegmentedControl(
                    labels: const ['English', 'Yoruba', 'Reading'],
                    selectedIndex: _book,
                    onValueChanged: (index) => setState(() {
                      _book = index;
                      _watchProvider();
                    }),
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.search,
                                size: 56,
                                color: secondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hymns found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.label.resolveFrom(
                                    context,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a hymn number or other words',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      // One swiped-open row at a time.
                      : GlassSwipeActionScope(
                          child: ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              bottom: insets.bottom + 16,
                            ),
                            itemCount: results.length,
                            itemBuilder: (ctx, i) => HymnListItem(
                              hymn: results[i],
                              provider: _provider!,
                              showFavorite: false,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
