import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/platform_icons.dart';

/// A number index down the right edge, like the A–Z index in Contacts.
///
/// Touch or drag along it to scrub through the book: a bubble shows the hymn
/// under the finger, and [onSelected] gets its position in [ids]. A few
/// numbers are printed as landmarks; a light tick marks passing each one.
class HymnIndexBar extends StatefulWidget {
  const HymnIndexBar({super.key, required this.ids, required this.onSelected});

  /// Hymn numbers, in list order.
  final List<int> ids;
  final ValueChanged<int> onSelected;

  static const double width = 24;

  @override
  State<HymnIndexBar> createState() => _HymnIndexBarState();
}

class _HymnIndexBarState extends State<HymnIndexBar> {
  int? _index;
  double _y = 0;
  int? _landmark;

  static const double _labelHeight = 16;

  /// Round numbers spread down the bar: as many as fit, at least 25 apart.
  List<int> _landmarks(double height) {
    final ids = widget.ids;
    if (ids.isEmpty) return const [];
    final fit = (height / (_labelHeight + 22)).floor().clamp(2, 30);
    final span = ids.last - ids.first;
    final step = [
      25,
      50,
      100,
      200,
      500,
    ].firstWhere((s) => span / s + 1 <= fit, orElse: () => 1000);
    return [
      ids.first,
      for (var n = step; n <= ids.last; n += step)
        if (n - ids.first >= step / 2) n,
    ];
  }

  int _indexOfId(int id) {
    final i = widget.ids.indexWhere((h) => h >= id);
    return i < 0 ? widget.ids.length - 1 : i;
  }

  void _scrub(double y, double height, List<int> landmarks) {
    final n = widget.ids.length;
    final index = ((y / height).clamp(0.0, 1.0) * (n - 1)).round();
    final id = widget.ids[index];
    final landmark = landmarks.lastWhere((l) => l <= id, orElse: () => id);
    if (_landmark != null && landmark != _landmark) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _index = index;
      _y = y.clamp(0.0, height);
      _landmark = landmark;
    });
    widget.onSelected(index);
  }

  void _end() => setState(() {
    _index = null;
    _landmark = null;
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor(context);
    final isIOS = PlatformInfo.isIOS;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final landmarks = _landmarks(height);
        final n = widget.ids.length;
        double yOf(int id) =>
            n < 2 ? 0 : _indexOfId(id) / (n - 1) * (height - _labelHeight);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Semantics(
                label: 'Hymn number index',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (d) =>
                      _scrub(d.localPosition.dy, height, landmarks),
                  onVerticalDragUpdate: (d) =>
                      _scrub(d.localPosition.dy, height, landmarks),
                  onVerticalDragEnd: (_) => _end(),
                  onVerticalDragCancel: _end,
                  onTapDown: (d) =>
                      _scrub(d.localPosition.dy, height, landmarks),
                  onTapUp: (_) => _end(),
                  onTapCancel: _end,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // Android shows a track while scrubbing, as its fast
                      // scrollers do; iOS keeps the index bare.
                      color: !isIOS && _index != null
                          ? Theme.of(context).colorScheme.surfaceContainerHigh
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            for (final id in landmarks)
              Positioned(
                top: yOf(id),
                left: 0,
                right: 0,
                height: _labelHeight,
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      '$id',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: accent,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            if (_index != null)
              Positioned(
                right: HymnIndexBar.width + 12,
                top: _y - 28,
                child: IgnorePointer(child: _bubble(context, accent)),
              ),
          ],
        );
      },
    );
  }

  Widget _bubble(BuildContext context, Color accent) {
    return Container(
      width: 64,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '${widget.ids[_index!]}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
