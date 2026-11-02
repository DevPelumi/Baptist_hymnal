import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show
        GlassModalSheet,
        GlassSegment,
        GlassSegmentedControl,
        GlassSheetDetent,
        GlassSlider,
        GlassSwitch;

import '../audio/tune_player.dart';
import '../utils/platform_icons.dart';
import 'tune_parts.dart';

/// Opens the full player for [tune]: a liquid glass sheet on iOS, a
/// Material bottom sheet on Android.
Future<void> showTuneSheet(BuildContext context, HymnTune tune) {
  if (!PlatformInfo.isIOS) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => TuneSheet(tune: tune),
    );
  }
  return GlassModalSheet.show<void>(
    context: context,
    detents: const {GlassSheetDetent.medium},
    halfSize: TuneSheet.height + MediaQuery.paddingOf(context).bottom,
    // The sheet covers the banner ad, a native view the glass shader can't
    // see through: without this it draws a black slab there. It also rules
    // out the morph from the mini player, so the sheet slides up instead.
    platformViewBackdrop: true,
    // Dim the page only lightly, as iOS does under a medium sheet; the
    // default darkens light-mode glass to grey.
    barrierColor: const Color(0x33000000),
    // Frosted enough to read small text over the lyrics and the ad.
    settings: tuneGlass(context),
    // Dragging the scrubber shouldn't light up or swell the whole sheet.
    enableInteractionGlow: false,
    enableSaturationGlow: false,
    suppressInteractionOnChildren: true,
    builder: (_) => Material(
      type: MaterialType.transparency,
      child: TuneSheet(tune: tune),
    ),
  );
}

/// The full player: scrubber, transport, verse, speed and repeat.
class TuneSheet extends StatefulWidget {
  const TuneSheet({super.key, required this.tune});

  final HymnTune tune;

  /// Room the content needs on iOS, where the sheet has a fixed height.
  static const double height = 464;

  @override
  State<TuneSheet> createState() => _TuneSheetState();
}

class _TuneSheetState extends State<TuneSheet> {
  final TunePlayer _player = TunePlayer.instance;
  late final Future<Duration> _passLength = _player.passLength(
    widget.tune.midiAsset,
  );

  // Where the scrubber's thumb is while it is held.
  double? _scrubbing;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Duration>(
      future: _passLength,
      builder: (context, pass) => ListenableBuilder(
        listenable: _player,
        builder: (context, _) => _build(context, pass.data ?? Duration.zero),
      ),
    );
  }

  Widget _build(BuildContext context, Duration passLength) {
    final tune = widget.tune;
    final isIOS = PlatformInfo.isIOS;
    final active = _player.isPlayingHymn(tune.hymnId);
    final state = active ? _player.state : TuneState.stopped;
    final ready = state == TuneState.playing || state == TuneState.paused;
    final total = ready
        ? _player.duration
        : passLength * (tune.verseCount / _player.speed);
    final progress = _scrubbing ?? (active ? _player.progress : 0.0);
    final elapsed = total * progress;
    final secondary = secondaryLabelColor(context);

    // Most hymns have no refrain, so only say so when the tune plays one.
    final shape = tune.includesRefrain == true
        ? 'Verse and refrain'
        : tune.verseCount > 1
        ? '${tune.verseCount} verses'
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        isIOS ? 28 : 0,
        24,
        isIOS ? 8 + MediaQuery.paddingOf(context).bottom : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TuneArtwork(hymnId: tune.hymnId, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tune.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Alata',
                        color: labelColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ['Hymn ${tune.hymnId}', ?shape].join(' · '),
                      style: TextStyle(fontSize: 14, color: secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _scrubber(context, progress, enabled: ready),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: secondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(elapsed)),
                  Text('−${formatTime(total - elapsed)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TuneGlyphButton(
                tooltip: 'Previous verse',
                size: 56,
                iconSize: 30,
                icon: isIOS
                    ? CupertinoIcons.backward_fill
                    : Icons.skip_previous_rounded,
                onPressed: ready ? _player.previousVerse : null,
              ),
              const SizedBox(width: 28),
              TunePlayButton(tune: tune, size: 72, iconSize: 46),
              const SizedBox(width: 28),
              TuneGlyphButton(
                tooltip: 'Next verse',
                size: 56,
                iconSize: 30,
                icon: isIOS
                    ? CupertinoIcons.forward_fill
                    : Icons.skip_next_rounded,
                onPressed: _player.hasNextVerse && active
                    ? _player.nextVerse
                    : null,
              ),
            ],
          ),
          if (tune.verseCount > 1) ...[
            const SizedBox(height: 20),
            _caption(context, 'Verse'),
            _picker<int>(
              context,
              values: [for (var i = 0; i < tune.verseCount; i++) i],
              label: (i) => '${i + 1}',
              selected: ready ? _player.verseNumber - 1 : 0,
              onSelected: (i) =>
                  ready ? _player.playVerse(i) : tune.play(startVerse: i),
            ),
          ],
          const SizedBox(height: 16),
          _caption(context, 'Speed'),
          _picker<double>(
            context,
            values: TunePlayer.speeds,
            label: speedLabel,
            selected: _player.speed,
            onSelected: _player.setSpeed,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Repeat hymn',
                  style: TextStyle(fontSize: 16, color: labelColor(context)),
                ),
              ),
              if (isIOS)
                GlassSwitch(
                  value: _player.repeat,
                  activeColor: accentColor(context),
                  semanticLabel: 'Repeat hymn',
                  onChanged: _player.setRepeat,
                )
              else
                Switch(value: _player.repeat, onChanged: _player.setRepeat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scrubber(
    BuildContext context,
    double value, {
    required bool enabled,
  }) {
    void onChanged(double v) => setState(() => _scrubbing = v);
    void onChangeEnd(double v) {
      _player.seekTo(v);
      setState(() => _scrubbing = null);
    }

    if (PlatformInfo.isIOS) {
      return GlassSlider(
        value: value,
        activeColor: accentColor(context),
        onChanged: enabled ? onChanged : null,
        onChangeEnd: enabled ? onChangeEnd : null,
      );
    }
    return Slider(
      value: value,
      onChanged: enabled ? onChanged : null,
      onChangeEnd: enabled ? onChangeEnd : null,
    );
  }

  Widget _caption(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: secondaryLabelColor(context),
      ),
    ),
  );

  /// A row of choices: glass segments on iOS, a segmented button on Android.
  Widget _picker<T>(
    BuildContext context, {
    required List<T> values,
    required String Function(T) label,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    if (PlatformInfo.isIOS) {
      return GlassSegmentedControl(
        segments: [for (final v in values) GlassSegment(label: label(v))],
        selectedIndex: values.indexOf(selected).clamp(0, values.length - 1),
        onSegmentSelected: (i) => onSelected(values[i]),
      );
    }
    return SegmentedButton<T>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      segments: [
        for (final v in values) ButtonSegment(value: v, label: Text(label(v))),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onSelected(s.single),
    );
  }
}
