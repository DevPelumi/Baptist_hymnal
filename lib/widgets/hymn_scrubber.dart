import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show GlassContainer, LiquidGlassSettings, LiquidRoundedSuperellipse;

import '../utils/platform_icons.dart';

/// A scroll thumb on the right of [child] that can be grabbed to scrub
/// through a long list, as with the iOS scroll indicator or an Android fast
/// scroller. It shows while the list scrolls and fades when it stops. While
/// it is dragged, a bubble beside it shows [labelAt]: the hymn at the top.
class HymnScrubber extends StatefulWidget {
  const HymnScrubber({
    super.key,
    required this.controller,
    required this.labelAt,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final ScrollController controller;

  /// The hymn number and title at the current scroll position.
  final (int, String)? Function() labelAt;

  /// Keeps the thumb clear of the bars at the top and bottom.
  final EdgeInsets padding;

  final Widget child;

  @override
  State<HymnScrubber> createState() => _HymnScrubberState();
}

class _HymnScrubberState extends State<HymnScrubber> {
  static const double _thumbHeight = 48;
  static const double _touchWidth = 44;
  static const Duration _linger = Duration(seconds: 2);

  bool _visible = false;
  bool _dragging = false;
  Timer? _hide;
  int? _lastTick;

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  bool get _worthScrubbing {
    final c = widget.controller;
    if (!c.hasClients || !c.position.hasContentDimensions) return false;
    final p = c.position;
    return p.maxScrollExtent > p.viewportDimension * 3;
  }

  void _show() {
    _hide?.cancel();
    if (!_visible) setState(() => _visible = true);
    if (!_dragging) {
      _hide = Timer(_linger, () {
        if (mounted) setState(() => _visible = false);
      });
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification && n.depth == 0 && _worthScrubbing) {
      _show();
    }
    return false;
  }

  void _scrub(double y, double track) {
    final p = widget.controller.position;
    final fraction = ((y - _thumbHeight / 2) / (track - _thumbHeight)).clamp(
      0.0,
      1.0,
    );
    widget.controller.jumpTo(fraction * p.maxScrollExtent);
    // A tick each 50 hymns, like the detents of the iOS date scrubber.
    final tick = (widget.labelAt()?.$1 ?? 0) ~/ 50;
    if (_lastTick != null && tick != _lastTick) HapticFeedback.selectionClick();
    _lastTick = tick;
  }

  void _start() {
    HapticFeedback.selectionClick();
    _lastTick = null;
    setState(() => _dragging = true);
    _show();
  }

  void _end() {
    setState(() => _dragging = false);
    _show();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.child,
        ),
        Positioned.fill(
          child: Padding(
            padding: widget.padding,
            child: LayoutBuilder(
              builder: (context, constraints) => ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) => _thumb(context, constraints.maxHeight),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thumb(BuildContext context, double track) {
    final c = widget.controller;
    if (!c.hasClients || !c.position.hasContentDimensions) {
      return const SizedBox.shrink();
    }
    final p = c.position;
    final fraction = p.maxScrollExtent <= 0
        ? 0.0
        : (p.pixels / p.maxScrollExtent).clamp(0.0, 1.0);
    final top = fraction * (track - _thumbHeight);
    final shown = _visible || _dragging;
    final label = _dragging ? widget.labelAt() : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: 0,
          top: top - 8,
          width: _touchWidth,
          height: _thumbHeight + 16,
          child: IgnorePointer(
            ignoring: !shown,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _start(),
              onVerticalDragUpdate: (d) =>
                  _scrub(d.globalPosition.dy - _trackTop(context), track),
              onVerticalDragEnd: (_) => _end(),
              onVerticalDragCancel: _end,
              child: AnimatedOpacity(
                opacity: shown ? 1 : 0,
                duration: Duration(milliseconds: shown ? 120 : 300),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _bar(context),
                ),
              ),
            ),
          ),
        ),
        if (label != null)
          Positioned(
            right: _touchWidth + 4,
            top: top + _thumbHeight / 2 - 28,
            child: IgnorePointer(
              child: _Bubble(number: label.$1, title: label.$2),
            ),
          ),
      ],
    );
  }

  /// Where the track starts on screen, to turn the finger's position into a
  /// position along it.
  double _trackTop(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box?.localToGlobal(Offset.zero).dy ?? 0;
  }

  Widget _bar(BuildContext context) {
    final isIOS = PlatformInfo.isIOS;
    // iOS: the thin grey scroll indicator, which thickens when grabbed.
    // Android: an accent-coloured fast-scroll thumb.
    final width = isIOS ? (_dragging ? 8.0 : 5.0) : (_dragging ? 10.0 : 7.0);
    final color = isIOS
        ? labelColor(context).withValues(alpha: _dragging ? 0.55 : 0.35)
        : accentColor(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: EdgeInsets.only(right: isIOS ? 3 : 4),
      width: width,
      height: _thumbHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width),
      ),
    );
  }
}

/// The hymn the scrubber is on: its number large, its title beneath.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 220),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: accentColor(context),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: labelColor(context)),
            ),
          ],
        ),
      ),
    );
    if (PlatformInfo.isIOS) {
      return GlassContainer(
        useOwnLayer: true,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        settings: LiquidGlassSettings(
          blur: 16,
          glassColor: CupertinoColors.systemBackground
              .resolveFrom(context)
              .withValues(alpha: 0.72),
        ),
        child: content,
      );
    }
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}
