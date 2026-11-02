import 'dart:math' as math;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../audio/tune_player.dart';
import '../utils/platform_icons.dart';

/// A hymn's tune, as the player screens need it.
class HymnTune {
  const HymnTune({
    required this.hymnId,
    required this.title,
    required this.midiAsset,
    required this.verseCount,
    this.includesRefrain,
  });

  final int hymnId;
  final String title;
  final String midiAsset;
  final int verseCount;

  /// Whether one play of the tune includes the refrain; null when unknown.
  final bool? includesRefrain;

  void play({int startVerse = 0}) => TunePlayer.instance.play(
    hymnId,
    midiAsset,
    verses: verseCount,
    startVerse: startVerse,
  );
}

/// Starts, pauses or resumes [tune], whichever fits.
void toggleTune(HymnTune tune) {
  final player = TunePlayer.instance;
  if (!player.isPlayingHymn(tune.hymnId)) {
    tune.play();
  } else if (player.state == TuneState.playing) {
    player.pause();
  } else if (player.state == TuneState.paused) {
    player.resume();
  }
}

String speedLabel(double speed) =>
    '${speed == speed.roundToDouble() ? speed.toInt() : speed}×';

/// One line on where the tune is: the verse, and the speed when changed.
String tuneStatus(HymnTune tune) {
  final player = TunePlayer.instance;
  if (!player.isPlayingHymn(tune.hymnId)) {
    return tune.verseCount > 1
        ? 'Hymn tune · ${tune.verseCount} verses'
        : 'Hymn tune';
  }
  if (player.state == TuneState.loading) return 'Loading…';
  return [
    player.verseCount > 1
        ? 'Verse ${player.verseNumber} of ${player.verseCount}'
        : 'Hymn tune',
    if (player.speed != 1) speedLabel(player.speed),
  ].join(' · ');
}

String formatTime(Duration d) {
  final seconds = d.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

Color tuneAccent(BuildContext context) => PlatformInfo.isIOS
    ? CupertinoColors.systemGreen.resolveFrom(context)
    : brandGreen;

Color tuneLabel(BuildContext context) => PlatformInfo.isIOS
    ? CupertinoColors.label.resolveFrom(context)
    : Theme.of(context).colorScheme.onSurface;

Color tuneSecondaryLabel(BuildContext context) => PlatformInfo.isIOS
    ? CupertinoColors.secondaryLabel.resolveFrom(context)
    : Theme.of(context).colorScheme.onSurfaceVariant;

/// The hymn's number on a green tile, in place of album art.
class TuneArtwork extends StatelessWidget {
  const TuneArtwork({super.key, required this.hymnId, required this.size});

  final int hymnId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final large = size >= 64;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(size * 0.24),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CC46A), Color(0xFF1E7A3C)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (large)
            Icon(
              platformIconData(
                cupertino: CupertinoIcons.music_note_2,
                material: Icons.music_note_rounded,
              ),
              size: size * 0.22,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          Text(
            '$hymnId',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * (hymnId >= 100 ? 0.32 : 0.4),
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// A bare glyph button: Cupertino's pressed fade on iOS, an ink ripple on
/// Android.
class TuneGlyphButton extends StatelessWidget {
  const TuneGlyphButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 24,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final base = color ?? tuneLabel(context);
    final glyph = Icon(
      icon,
      size: iconSize,
      color: enabled ? base : base.withValues(alpha: 0.3),
    );
    if (!PlatformInfo.isIOS) {
      return IconButton(
        tooltip: tooltip,
        constraints: BoxConstraints.tight(Size.square(size)),
        padding: EdgeInsets.zero,
        icon: glyph,
        onPressed: onPressed,
      );
    }
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.square(size),
        onPressed: onPressed,
        child: glyph,
      ),
    );
  }
}

/// Play/pause for [tune], with a spinner while the soundfont loads and, when
/// [showProgress], a ring that fills as the hymn plays.
class TunePlayButton extends StatelessWidget {
  const TunePlayButton({
    super.key,
    required this.tune,
    this.size = 44,
    this.iconSize = 22,
    this.showProgress = false,
  });

  final HymnTune tune;
  final double size;
  final double iconSize;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final player = TunePlayer.instance;
    final active = player.isPlayingHymn(tune.hymnId);
    final state = active ? player.state : TuneState.stopped;
    if (state == TuneState.loading) {
      return SizedBox.square(
        dimension: size,
        child: Center(
          child: PlatformInfo.isIOS
              ? const CupertinoActivityIndicator()
              : SizedBox.square(
                  dimension: iconSize,
                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                ),
        ),
      );
    }
    final playing = state == TuneState.playing;
    final button = TuneGlyphButton(
      tooltip: playing ? 'Pause tune' : 'Play tune',
      size: size,
      iconSize: iconSize,
      icon: platformIconData(
        cupertino: playing
            ? CupertinoIcons.pause_fill
            : CupertinoIcons.play_fill,
        material: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
      ),
      onPressed: () => toggleTune(tune),
    );
    if (!showProgress) return button;
    final accent = tuneAccent(context);
    return CustomPaint(
      foregroundPainter: _RingPainter(
        progress: active ? player.progress : 0,
        color: accent,
        track: tuneLabel(context).withValues(alpha: 0.12),
      ),
      child: button,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  static const double _stroke = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - 5,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
