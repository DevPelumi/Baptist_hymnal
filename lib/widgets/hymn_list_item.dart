import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show
        GlassContextMenu,
        GlassContextMenuAction,
        GlassMenu,
        GlassMenuAlignment,
        GlassMenuItem,
        GlassSwipeAction,
        GlassSwipeActions;

import '../models/hymn_data.dart';
import '../providers/hymn_provider.dart';
import '../screens/details_screen.dart';
import '../utils/hymn_helper_functions.dart';
import '../utils/platform_icons.dart';
import '../utils/share_hymn.dart';
import '../utils/app_font.dart';

/// A hymn row, laid out like a song in Apple Music: the number in a circle
/// where the artwork goes, the title over the hymn's opening words, and a
/// "…" button for its actions.
///
/// iOS also takes a swipe right to favourite, left to share, and a touch and
/// hold for a preview of the first verse. Android takes a touch and hold for
/// the same menu as "…".
class HymnListItem extends StatelessWidget {
  final HymnData hymn;
  final IHymnProvider provider;
  final bool showFavorite;

  const HymnListItem({
    super.key,
    required this.hymn,
    required this.provider,
    this.showFavorite = true,
  });

  static final double _badge = PlatformInfo.isIOS ? 44 : 40;
  static const double _gap = 12;

  /// Every row is this tall, so the scrubber can land on any hymn. It grows
  /// with the text size; the title and subtitle stay on one line each.
  static double extent(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final text = (scaler.scale(17) + scaler.scale(15)) * 1.25 + 2;
    final min = PlatformInfo.isIOS ? 64.0 : 72.0;
    return (text + 20).clamp(min, 160);
  }

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

  String _favouriteLabel(bool isFavorite) => PlatformInfo.isIOS
      ? (isFavorite ? 'Remove from Favourites' : 'Add to Favourites')
      : (isFavorite ? 'Remove from favourites' : 'Add to favourites');

  @override
  Widget build(BuildContext context) {
    final isFavorite = provider.isFavorite(hymn.id);
    return PlatformInfo.isIOS
        ? _ios(context, isFavorite)
        : _android(context, isFavorite);
  }

  Widget _row(BuildContext context, bool isFavorite, Widget more) {
    final isIOS = PlatformInfo.isIOS;
    final subtitle = HymnHelperFunctions.openingLine(hymn);
    return SizedBox(
      height: extent(context),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            _NumberBadge(id: hymn.id, size: _badge),
            const SizedBox(width: _gap),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hymn.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isIOS
                        ? TextStyle(fontSize: 17, color: labelColor(context))
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isIOS
                          ? TextStyle(
                              fontSize: 15,
                              color: secondaryLabelColor(context),
                            )
                          : Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: secondaryLabelColor(context),
                            ),
                    ),
                  ],
                ],
              ),
            ),
            if (showFavorite && isFavorite)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  platformIconData(
                    cupertino: CupertinoIcons.heart_fill,
                    material: Icons.favorite,
                  ),
                  semanticLabel: 'Favourite',
                  color: CupertinoColors.systemPink.resolveFrom(context),
                  size: 14,
                ),
              ),
            more,
          ],
        ),
      ),
    );
  }

  Widget _ios(BuildContext context, bool isFavorite) {
    final heart = isFavorite
        ? CupertinoIcons.heart_slash_fill
        : CupertinoIcons.heart_fill;
    // The "…" pull-down: a glass menu that grows out of the button.
    final more = GlassMenu(
      menuAlignment: GlassMenuAlignment.topRight,
      autoAdjustToScreen: true,
      menuWidth: 250,
      semanticLabel: 'More actions',
      trigger: SizedBox.square(
        dimension: 44,
        child: Icon(
          CupertinoIcons.ellipsis,
          size: 20,
          color: labelColor(context),
        ),
      ),
      items: [
        GlassMenuItem(
          title: _favouriteLabel(isFavorite),
          icon: Icon(heart),
          onTap: _toggleFavorite,
        ),
        GlassMenuItem(
          title: 'Share',
          icon: const Icon(CupertinoIcons.share),
          onTap: () => shareHymn(context, hymn),
        ),
      ],
    );
    // Separators start at the title, as in iOS lists.
    final tile = _PressableRow(
      onTap: () => _open(context),
      separatorIndent: 16 + _badge + _gap,
      child: _row(context, isFavorite, more),
    );
    return GlassSwipeActions(
      leadingActions: [
        GlassSwipeAction(
          // Icon-only, as in iOS 26 Mail; a label under the button is too
          // faint to read over the list.
          icon: Icon(heart),
          semanticLabel: isFavorite ? 'Unfavourite' : 'Favourite',
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
            child: Text(_favouriteLabel(isFavorite)),
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

  Widget _android(BuildContext context, bool isFavorite) {
    List<PopupMenuEntry<String>> items() => [
      PopupMenuItem(
        value: 'favourite',
        child: ListTile(
          leading: Icon(
            isFavorite ? Icons.heart_broken_outlined : Icons.favorite_border,
          ),
          title: Text(_favouriteLabel(isFavorite)),
        ),
      ),
      const PopupMenuItem(
        value: 'share',
        child: ListTile(leading: Icon(Icons.share), title: Text('Share')),
      ),
    ];
    void onSelected(String choice) {
      switch (choice) {
        case 'favourite':
          _toggleFavorite();
        case 'share':
          shareHymn(context, hymn);
      }
    }

    final more = PopupMenuButton<String>(
      tooltip: 'More actions',
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => items(),
      onSelected: onSelected,
    );
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
            items: items(),
          );
          if (choice != null && context.mounted) onSelected(choice);
        },
        child: _row(context, isFavorite, more),
      ),
    );
  }
}

/// The hymn number in a green circle, where Apple Music puts the artwork.
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.id, required this.size});

  final int id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor(context),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$id',
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontFamily: numberFont,
          color: Colors.white,
          fontSize: id >= 100 ? size * 0.33 : size * 0.38,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

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
                fontFamily: numberFont,
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
