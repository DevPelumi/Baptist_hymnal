import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../audio/tune_player.dart';
import '../data/hymn_audio.dart';
import '../utils/platform_icons.dart';

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
    final isIOS = PlatformInfo.isIOS;
    final accent = isIOS
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : brandGreen;
    final barColor = isIOS
        ? CupertinoColors.secondarySystemBackground.resolveFrom(context)
        : Theme.of(context).colorScheme.surfaceContainer;
    return ListenableBuilder(
      listenable: _player,
      builder: (context, _) {
        final active = _player.isPlayingHymn(widget.hymnId);
        final state = active ? _player.state : TuneState.stopped;
        final playing = state == TuneState.playing;
        // Material gives the icon buttons and progress bar their ink on iOS,
        // where the page itself is Cupertino.
        return Material(
          color: barColor,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: 4),
                SizedBox(
                  width: 48,
                  child: state == TuneState.loading
                      ? Center(
                          child: isIOS
                              ? const CupertinoActivityIndicator()
                              : const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                ),
                        )
                      : IconButton(
                          tooltip: playing ? 'Pause tune' : 'Play tune',
                          icon: Icon(
                            platformIconData(
                              cupertino: playing
                                  ? CupertinoIcons.pause_circle_fill
                                  : CupertinoIcons.play_circle_fill,
                              material: playing
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                            ),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: active ? _player.progress : 0,
                          minHeight: 3,
                          color: accent,
                          backgroundColor: accent.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AdaptivePopupMenuButton.text<double>(
                  label: _speedLabel(_player.speed),
                  tint: accent,
                  items: [
                    for (final speed in TunePlayer.speeds)
                      AdaptivePopupMenuItem<double>(
                        label: _speedLabel(speed),
                        value: speed,
                        selected: speed == _player.speed,
                      ),
                  ],
                  onSelected: (_, item) {
                    final speed = item.value;
                    if (speed != null) _player.setSpeed(speed);
                  },
                ),
                IconButton(
                  tooltip: _player.repeat ? 'Repeat on' : 'Repeat off',
                  icon: Icon(
                    platformIconData(
                      cupertino: CupertinoIcons.repeat,
                      material:
                          _player.repeat ? Icons.repeat_on : Icons.repeat,
                    ),
                    color: _player.repeat
                        ? accent
                        : CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                  onPressed: () => _player.setRepeat(!_player.repeat),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
