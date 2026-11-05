import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show GlassContainer, LiquidRoundedSuperellipse;

import '../audio/tune_player.dart';
import '../utils/platform_icons.dart';
import 'tune_parts.dart';
import 'tune_sheet.dart';

/// A player that floats over the bottom of the hymn page: play/pause, the
/// next verse, and a tap to open the full player. Liquid glass on iOS, a
/// Material card on Android. Stops the tune when the hymn page goes away.
class TuneMiniPlayer extends StatefulWidget {
  const TuneMiniPlayer({super.key, required this.tune});

  final HymnTune tune;

  static const double height = 64;

  @override
  State<TuneMiniPlayer> createState() => _TuneMiniPlayerState();
}

class _TuneMiniPlayerState extends State<TuneMiniPlayer> {
  final TunePlayer _player = TunePlayer.instance;

  @override
  void dispose() {
    _player.stop(hymnId: widget.tune.hymnId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ListenableBuilder(
      listenable: _player,
      builder: (context, _) => _content(context),
    );
    if (!PlatformInfo.isIOS) {
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        // Just enough shadow to lift it off the lyrics.
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showTuneSheet(context, widget.tune),
          child: SizedBox(height: TuneMiniPlayer.height, child: content),
        ),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showTuneSheet(context, widget.tune),
      child: GlassContainer(
        // Its own layer, so it gets the player's frosted settings rather than
        // the default clear glass, which let the lyrics show through its text.
        useOwnLayer: true,
        settings: tuneGlass(context),
        // The same frosted backdrop blur as the full player sheet, so the two
        // look alike. It also draws properly next to the banner ad, a native
        // view the glass shader can't see.
        platformViewBackdrop: true,
        height: TuneMiniPlayer.height,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: TuneMiniPlayer.height / 2,
        ),
        child: content,
      ),
    );
  }

  Widget _content(BuildContext context) {
    final tune = widget.tune;
    final active = _player.isPlayingHymn(tune.hymnId);
    return Row(
      children: [
        const SizedBox(width: 10),
        TuneArtwork(hymnId: tune.hymnId, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tune.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: labelColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tuneStatus(tune),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryLabelColor(context),
                ),
              ),
            ],
          ),
        ),
        TunePlayButton(tune: tune, showProgress: true),
        TuneGlyphButton(
          tooltip: 'Next verse',
          icon: PlatformInfo.isIOS
              ? CupertinoIcons.forward_fill
              : Icons.skip_next_rounded,
          onPressed: active && _player.hasNextVerse ? _player.nextVerse : null,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
