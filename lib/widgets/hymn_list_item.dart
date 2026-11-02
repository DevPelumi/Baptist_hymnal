import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show
        GlassContextMenu,
        GlassContextMenuAction,
        GlassSwipeAction,
        GlassSwipeActions;

import '../models/hymn_data.dart';
import '../providers/hymn_provider.dart';
import '../screens/details_screen.dart';
import '../utils/platform_icons.dart';
import '../utils/share_hymn.dart';

/// A hymn row: its number, its title, and a heart when it is a favourite.
///
/// iOS: swipe right to favourite, left to share, or touch and hold for a
/// preview of the first verse with the same actions. Android: touch and hold
/// for a menu.
class HymnListItem extends StatelessWidget {
  final HymnData hymn;
  final IHymnProvider provider;
  final bool showFavorite;

  /// Extra space on the right, to clear the number index.
  final double endInset;

  const HymnListItem({
    super.key,
    required this.hymn,
    required this.provider,
    this.showFavorite = true,
    this.endInset = 0,
  });

  /// Every row is this tall, so a list can jump straight to any hymn.
  /// Titles stay on one line; the height grows with the text size.
  static double extent(BuildContext context) {
    final text = MediaQuery.textScalerOf(context).scale(17);
    return (text + (PlatformInfo.isIOS ? 28 : 34)).clamp(48, 120);
  }

  static const double _numberWidth = 40;
  static const double _gap = 14;

  void _open(BuildContext context) {
    // Otherwise the search field takes focus back, and the keyboard with it,
    // when the user returns from the hymn.
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(hymn: hymn, provider: provider),
      ),
    );
  }

  void _toggleFavorite() => provider.toggleFavoriteForHymn(hymn.id);

  @override
  Widget build(BuildContext context) {
    final isFavorite = provider.isFavorite(hymn.id);
    final row = _content(context, isFavorite);
    return PlatformInfo.isIOS
        ? _ios(context, row, isFavorite)
        : _android(context, row, isFavorite);
  }

  Widget _content(BuildContext context, bool isFavorite) {
    final isIOS = PlatformInfo.isIOS;
    return SizedBox(
      height: extent(context),
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16 + endInset),
        child: Row(
          children: [
            SizedBox(
              width: _numberWidth,
              child: Text(
                '${hymn.id}',
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: _gap),
            Expanded(
              child: Text(
                hymn.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isIOS
                    ? TextStyle(fontSize: 17, color: labelColor(context))
                    : Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (showFavorite && isFavorite)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  platformIconData(
                    cupertino: CupertinoIcons.heart_fill,
                    material: Icons.favorite,
                  ),
                  semanticLabel: 'Favourite',
                  color: CupertinoColors.systemPink.resolveFrom(context),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _ios(BuildContext context, Widget row, bool isFavorite) {
    final favouriteLabel = isFavorite ? 'Unfavourite' : 'Favourite';
    final heart = isFavorite
        ? CupertinoIcons.heart_slash_fill
        : CupertinoIcons.heart_fill;
    // Separators start at the title, as in iOS lists.
    final tile = _PressableRow(
      onTap: () => _open(context),
      separatorIndent: 16 + _numberWidth + _gap,
      child: row,
    );
    return GlassSwipeActions(
      leadingActions: [
        GlassSwipeAction(
          // Icon-only, as in iOS 26 Mail; a label under the button is too
          // faint to read over the list.
          icon: Icon(heart),
          semanticLabel: favouriteLabel,
          backgroundColor: CupertinoColors.systemPink.resolveFrom(context),
          onTap: _toggleFavorite,
        ),
      ],
      trailingActions: [
        GlassSwipeAction(
          icon: const Icon(CupertinoIcons.share),
          semanticLabel: 'Share',
          backgroundColor: CupertinoColors.systemBlue.resolveFrom(context),
          onTap: () => shareHymn(context, hymn),
        ),
      ],
      child: GlassContextMenu(
        longPressDuration: const Duration(milliseconds: 500),
        previewBuilder: (_) => _HymnPreview(hymn: hymn),
        actions: [
          GlassContextMenuAction(
            icon: Icon(heart),
            onPressed: _toggleFavorite,
            child: Text(
              isFavorite ? 'Remove from Favourites' : 'Add to Favourites',
            ),
          ),
          GlassContextMenuAction(
            icon: const Icon(CupertinoIcons.share),
            onPressed: () => shareHymn(context, hymn),
            child: const Text('Share'),
          ),
        ],
        child: tile,
      ),
    );
  }

  Widget _android(BuildContext context, Widget row, bool isFavorite) {
    Offset? pressedAt;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _open(context),
        onTapDown: (details) => pressedAt = details.globalPosition,
        onLongPress: () async {
          final overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final at = pressedAt ?? overlay.size.center(Offset.zero);
          final choice = await showMenu<String>(
            context: context,
            position: RelativeRect.fromRect(
              at & Size.zero,
              Offset.zero & overlay.size,
            ),
            items: [
              PopupMenuItem(
                value: 'favourite',
                child: ListTile(
                  leading: Icon(
                    isFavorite ? Icons.heart_broken_outlined : Icons.favorite,
                  ),
                  title: Text(
                    isFavorite ? 'Remove from favourites' : 'Add to favourites',
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                ),
              ),
            ],
          );
          if (!context.mounted) return;
          switch (choice) {
            case 'favourite':
              _toggleFavorite();
            case 'share':
              shareHymn(context, hymn);
          }
        },
        child: row,
      ),
    );
  }
}

/// iOS row press: the grey highlight a UITableView cell shows while touched,
/// and a hairline separator from [separatorIndent] to the edge.
class _PressableRow extends StatefulWidget {
  const _PressableRow({
    required this.onTap,
    required this.separatorIndent,
    required this.child,
  });

  final VoidCallback onTap;
  final double separatorIndent;
  final Widget child;

  @override
  State<_PressableRow> createState() => _PressableRowState();
}

class _PressableRowState extends State<_PressableRow> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _pressed
                ? CupertinoColors.systemGrey4.resolveFrom(context)
                : CupertinoColors.systemBackground.resolveFrom(context),
          ),
          position: DecorationPosition.background,
          child: Stack(
            children: [
              widget.child,
              Positioned(
                left: widget.separatorIndent,
                right: 0,
                bottom: 0,
                height: 1 / MediaQuery.devicePixelRatioOf(context),
                child: ColoredBox(
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The context menu preview: the hymn's title and first verse, as a peek at
/// the page it opens.
class _HymnPreview extends StatelessWidget {
  const _HymnPreview({required this.hymn});

  final HymnData hymn;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    // Raised over the dimmed page: iOS's elevated background, which in dark
    // mode is a grey card instead of the black of the page.
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: (context) => _card(context, width)),
    );
  }

  Widget _card(BuildContext context, double width) {
    return Container(
      width: width,
      constraints: const BoxConstraints(maxHeight: 360),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HYMN ${hymn.id}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: accentColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hymn.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Alata',
                color: labelColor(context),
              ),
            ),
            const SizedBox(height: 10),
            if (hymn.contents.isNotEmpty)
              Text(
                hymn.contents.first.trim(),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontFamily: 'Alata',
                  color: labelColor(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
