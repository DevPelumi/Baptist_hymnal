import 'package:flutter/material.dart';

import '../audio/tune_player.dart';
import '../data/hymn_audio.dart';

/// Play/pause, progress, speed and repeat for a hymn's tune. Stops the tune
/// when the hymn page goes away.
class TuneControls extends StatefulWidget {
  const TuneControls({
    super.key,
    required this.hymnId,
    required this.midiAsset,
    required this.verseCount,
  });

  final int hymnId;
  final String midiAsset;
  final int verseCount;

  @override
  State<TuneControls> createState() => _TuneControlsState();
}

class _TuneControlsState extends State<TuneControls> {
  final TunePlayer _player = TunePlayer.instance;

  @override
  void dispose() {
    _player.stop(hymnId: widget.hymnId);
    super.dispose();
  }

  void _onPlayPressed() {
    if (!_player.isPlayingHymn(widget.hymnId)) {
      _player.play(
        widget.hymnId,
        widget.midiAsset,
        verses: widget.verseCount,
      );
    } else if (_player.state == TuneState.playing) {
      _player.pause();
    } else if (_player.state == TuneState.paused) {
      _player.resume();
    }
  }

  static String _speedLabel(double speed) =>
      '${speed == speed.roundToDouble() ? speed.toInt() : speed}×';

  String _label(bool active) {
    final refrain = englishTuneIncludesRefrain(widget.hymnId);
    final shape = switch (refrain) {
      true => 'Verse and refrain',
      false => 'One verse',
      null => 'Hymn tune',
    };
    final total = active ? _player.verseCount : widget.verseCount;
    if (total <= 1) return shape;
    final current = active ? _player.verseNumber : 1;
    return '$shape · $current of $total';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Colors.green.shade600;
    return ListenableBuilder(
      listenable: _player,
      builder: (context, _) {
        final active = _player.isPlayingHymn(widget.hymnId);
        final state = active ? _player.state : TuneState.stopped;
        return Container(
          color: isDark ? Colors.grey.shade900 : Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          height: 52,
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: state == TuneState.loading
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : IconButton(
                        tooltip: state == TuneState.playing ? 'Pause tune' : 'Play tune',
                        icon: Icon(
                          state == TuneState.playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: accent,
                          size: 34,
                        ),
                        onPressed: _onPlayPressed,
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(active),
                      style: TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: active ? _player.progress : 0,
                      minHeight: 3,
                      color: accent,
                      backgroundColor: accent.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<double>(
                tooltip: 'Tune speed',
                initialValue: _player.speed,
                onSelected: _player.setSpeed,
                itemBuilder: (context) => [
                  for (final speed in TunePlayer.speeds)
                    PopupMenuItem(value: speed, child: Text(_speedLabel(speed))),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _speedLabel(_player.speed),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: _player.repeat ? 'Repeat on' : 'Repeat off',
                icon: Icon(
                  _player.repeat ? Icons.repeat_on : Icons.repeat,
                  color: _player.repeat ? accent : Colors.grey,
                ),
                onPressed: () => _player.setRepeat(!_player.repeat),
              ),
            ],
          ),
        );
      },
    );
  }
}
