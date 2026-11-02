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
import '../widgets/hymn_index_bar.dart';
import '../widgets/hymn_list_item.dart';

/// One book (English, Yoruba or Responsive Reading): a header photo and every
/// hymn in it, with a search field at the top and a number index down the
/// side for jumping through the book.
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

  /// Scrolls so the hymn at [index] sits just below the bars, which take
  /// [barsHeight] off the top of the list.
  void _jumpTo(int index, double barsHeight) {
    final list = _listKey.currentContext?.findRenderObject();
    if (list is! RenderSliver || !_scroll.hasClients) return;
    final top = list.constraints.precedingScrollExtent - barsHeight;
    final offset = top + index * HymnListItem.extent(context);
    _scroll.jumpTo(offset.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: widget.title),
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return Consumer<T>(
            builder: (context, provider, _) {
              final hymns = HymnHelperFunctions.search(
                provider.dataSource,
                _query.text,
              );
              final showIndex = !_searching && hymns.length > 40;
              final list = GlassSwipeActionScope(
                child: CustomScrollView(
                  controller: _scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, insets.top + 8, 16, 12),
                      sliver: SliverToBoxAdapter(child: _searchField()),
                    ),
                    if (!_searching)
                      SliverPadding(
                        // Clear of the number index beside it.
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          showIndex ? 16 + HymnIndexBar.width : 16,
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
                      SliverFixedExtentList.builder(
                        key: _listKey,
                        itemExtent: HymnListItem.extent(context),
                        itemCount: hymns.length,
                        itemBuilder: (context, i) => HymnListItem(
                          hymn: hymns[i],
                          provider: provider,
                          endInset: showIndex ? HymnIndexBar.width - 8 : 0,
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
                  list,
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
                  if (showIndex)
                    Positioned(
                      right: 2,
                      // Below the search field, which is taller on Android.
                      top: insets.top + (PlatformInfo.isIOS ? 64 : 84),
                      bottom: insets.bottom + 16,
                      width: HymnIndexBar.width,
                      child: HymnIndexBar(
                        ids: [for (final h in hymns) h.id],
                        onSelected: (i) => _jumpTo(i, insets.top),
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
