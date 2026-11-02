import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderSliver;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show GlassSwipeActionScope;
import 'package:provider/provider.dart';

import '../providers/hymn_provider.dart';
import '../utils/hymn_helper_functions.dart';
import '../utils/platform_icons.dart';
import '../utils/responsive.dart';
import '../models/hymn_data.dart';
import '../widgets/hymn_list_item.dart';
import '../widgets/hymn_scrubber.dart';

/// One book (English, Yoruba or Responsive Reading): a header photo and every
/// hymn in it, with a search field at the top and a scrubber down the side
/// for jumping through the book.
class HymnListScreen<T extends IHymnProvider> extends StatefulWidget {
  const HymnListScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.searchTabIndex,
    this.imageAlignment = Alignment.center,
  });

  final String title;
  final String imagePath;
  final Alignment imageAlignment;

  /// The tab the Search screen opens on for this book.
  final int searchTabIndex;

  @override
  State<HymnListScreen<T>> createState() => _HymnListScreenState<T>();
}

class _HymnListScreenState<T extends IHymnProvider>
    extends State<HymnListScreen<T>> {
  final _scroll = ScrollController();
  final _query = TextEditingController();
  final _searchFocus = FocusNode();
  final _listKey = GlobalKey();

  // The hymns on show, for the scrubber's label.
  List<HymnData> _hymns = const [];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scroll.dispose();
    _query.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _searching => _query.text.trim().isNotEmpty;

  void _cancelSearch() {
    _query.clear();
    _searchFocus.unfocus();
    setState(() {});
  }

  /// The hymn at the top of the list, just below the bars, which take
  /// [barsHeight] off the top.
  (int, String)? _topHymn(double barsHeight) {
    final list = _listKey.currentContext?.findRenderObject();
    if (list is! RenderSliver || !_scroll.hasClients || _hymns.isEmpty) {
      return null;
    }
    final intoList =
        _scroll.offset + barsHeight - list.constraints.precedingScrollExtent;
    final i = (intoList / HymnListItem.extent(context)).floor().clamp(
      0,
      _hymns.length - 1,
    );
    return (_hymns[i].id, _hymns[i].title);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: widget.title),
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          // On a tablet the list is a centred column, not the full width.
          final side = Responsive.inset(context);
          return Consumer<T>(
            builder: (context, provider, _) {
              final hymns = HymnHelperFunctions.search(
                provider.dataSource,
                _query.text,
              );
              _hymns = hymns;
              final list = GlassSwipeActionScope(
                child: CustomScrollView(
                  controller: _scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + side,
                        insets.top + 8,
                        16 + side,
                        12,
                      ),
                      sliver: SliverToBoxAdapter(child: _searchField()),
                    ),
                    if (!_searching)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16 + side,
                          0,
                          16 + side,
                          8,
                        ),
                        sliver: SliverToBoxAdapter(child: _header()),
                      ),
                    if (hymns.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _noResults(context),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: side),
                        sliver: SliverFixedExtentList.builder(
                          key: _listKey,
                          itemExtent: HymnListItem.extent(context),
                          itemCount: hymns.length,
                          itemBuilder: (context, i) =>
                              HymnListItem(hymn: hymns[i], provider: provider),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: insets.bottom + 16),
                    ),
                  ],
                ),
              );
              return Stack(
                children: [
                  HymnScrubber(
                    controller: _scroll,
                    labelAt: () => _topHymn(insets.top),
                    padding: EdgeInsets.only(
                      top: insets.top + 8,
                      bottom: insets.bottom + 8,
                    ),
                    child: list,
                  ),
                  // iOS 26 bars float over the list, which fades out
                  // beneath them instead of showing through the title.
                  if (PlatformInfo.isIOS)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: insets.top + 12,
                      child: IgnorePointer(
                        child: _TopFade(
                          color: CupertinoColors.systemBackground.resolveFrom(
                            context,
                          ),
                          solidUntil: (insets.top - 2) / (insets.top + 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _header() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        widget.imagePath,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: widget.imageAlignment,
      ),
    );
  }

  Widget _searchField() {
    void onChanged(String _) => setState(() {});
    if (PlatformInfo.isIOS) {
      // iOS shows Cancel beside the field while searching.
      final editing = _searchFocus.hasFocus || _searching;
      return Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              controller: _query,
              focusNode: _searchFocus,
              placeholder: 'Number, title or words',
              onChanged: onChanged,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: editing
                ? CupertinoButton(
                    padding: const EdgeInsets.only(left: 12),
                    minimumSize: const Size(44, 36),
                    onPressed: _cancelSearch,
                    child: const Text('Cancel'),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    }
    return SearchBar(
      controller: _query,
      focusNode: _searchFocus,
      hintText: 'Number, title or words',
      leading: const Icon(Icons.search),
      elevation: const WidgetStatePropertyAll(0),
      onChanged: onChanged,
      trailing: [
        if (_searching)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: _cancelSearch,
          ),
      ],
    );
  }

  Widget _noResults(BuildContext context) {
    final secondary = secondaryLabelColor(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        children: [
          Icon(
            platformIconData(
              cupertino: CupertinoIcons.search,
              material: Icons.search_off,
            ),
            size: 48,
            color: secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No results for “${_query.text.trim()}”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: labelColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a hymn number, or words from the title or a verse.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: secondary),
          ),
        ],
      ),
    );
  }
}

/// The iOS 26 scroll edge under the top bar: the background, nearly solid
/// down to [solidUntil] (a fraction of the height), then fading to clear.
class _TopFade extends StatelessWidget {
  const _TopFade({required this.color, required this.solidUntil});

  final Color color;
  final double solidUntil;

  @override
  Widget build(BuildContext context) {
    final solid = solidUntil.clamp(0.0, 0.95);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            color.withValues(alpha: 0.94),
            color.withValues(alpha: 0.5),
            color.withValues(alpha: 0),
          ],
          stops: [0, solid, solid + (1 - solid) * 0.5, 1],
        ),
      ),
    );
  }
}
