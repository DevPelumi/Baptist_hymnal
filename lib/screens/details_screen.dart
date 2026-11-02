import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:baptist_hymnal/providers/responsive_reading_provider.dart';
import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/providers/yoruba_hymn_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:baptist_hymnal/ad_helper.dart";
import '../data/hymn_audio.dart';
import '../models/hymn_data.dart';
import '../utils/platform_icons.dart';
import '../utils/share_hymn.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/tune_mini_player.dart';
import '../widgets/tune_parts.dart';
import '../providers/hymn_provider.dart';
import '../providers/settings_provider.dart';

class DetailScreen extends StatefulWidget {
  final HymnData hymn;
  final IHymnProvider provider;

  const DetailScreen({super.key, required this.hymn, required this.provider});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Widget _getContentWidget(double fontSize) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    if (widget.provider is ResponsiveReadingProvider) {
      int counter = 0;
      return Column(
        children: widget.hymn.contents
            .map(
              (t) => Text(
                '$t\n',
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'Alata',
                  color: textColor,
                  fontStyle: counter % 2 == 0
                      ? FontStyle.normal
                      : FontStyle.italic,
                  fontWeight: (counter++) % 2 == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Text(
        widget.hymn.contents.join("\n"),
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Alata',
          color: textColor,
        ),
      );
    }
  }

  String _getHymnCategory() {
    if (widget.provider is EnglishHymnProvider) {
      return "English Hymn";
    } else if (widget.provider is YorubaHymnProvider) {
      return "Yoruba Hymn";
    } else if (widget.provider is ResponsiveReadingProvider) {
      return "Responsive Reading";
    }
    return ""; // Default or unknown category
  }

  void _navigateToHymn(HymnData hymn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailScreen(hymn: hymn, provider: widget.provider),
      ),
    );
  }

  HymnData? _getNextHymn() {
    final hymns = widget.provider.dataSource;
    final currentIndex = hymns.indexWhere((h) => h.id == widget.hymn.id);
    if (currentIndex < hymns.length - 1) {
      return hymns[currentIndex + 1];
    }
    return null;
  }

  HymnData? _getPreviousHymn() {
    final hymns = widget.provider.dataSource;
    final currentIndex = hymns.indexWhere((h) => h.id == widget.hymn.id);
    if (currentIndex > 0) {
      return hymns[currentIndex - 1];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Retries ad setup if it failed at launch (for example, opened offline).
    AdHelper.initialize().whenComplete(AdHelper.preloadInterstitialAd);
  }

  @override
  Widget build(BuildContext context) {
    final midiAsset = widget.provider is EnglishHymnProvider
        ? englishHymnAudioAsset(widget.hymn.id)
        : null;
    final tune = midiAsset == null
        ? null
        : HymnTune(
            hymnId: widget.hymn.id,
            title: widget.hymn.title,
            midiAsset: midiAsset,
            verseCount: englishHymnVerseCount(widget.hymn.contents),
            includesRefrain: englishTuneIncludesRefrain(widget.hymn.id),
          );
    final isFavorite = widget.provider.isFavorite(widget.hymn.id);

    // Fires for back button, system back and iOS swipe, but not when the
    // arrows replace this page with the next or previous hymn.
    return PopScope<Object?>(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) AdHelper.onHymnClosed();
      },
      child: AdaptiveScaffold(
        // No title: four actions leave no room for one on a phone, and the
        // page heading names the hymn.
        appBar: AdaptiveAppBar(
          actions: [
            AdaptiveAppBarAction(
              iosSymbol: 'chevron.left',
              icon: platformIconData(
                cupertino: CupertinoIcons.chevron_left,
                material: Icons.chevron_left,
              ),
              label: 'Previous hymn',
              onPressed: () {
                final prevHymn = _getPreviousHymn();
                if (prevHymn != null) _navigateToHymn(prevHymn);
              },
            ),
            AdaptiveAppBarAction(
              iosSymbol: 'chevron.right',
              icon: platformIconData(
                cupertino: CupertinoIcons.chevron_right,
                material: Icons.chevron_right,
              ),
              label: 'Next hymn',
              spacerAfter: ToolbarSpacerType.fixed,
              onPressed: () {
                final nextHymn = _getNextHymn();
                if (nextHymn != null) _navigateToHymn(nextHymn);
              },
            ),
            AdaptiveAppBarAction(
              iosSymbol: isFavorite ? 'heart.fill' : 'heart',
              icon: platformIconData(
                cupertino: isFavorite
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                material: isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              label: isFavorite
                  ? 'Remove from favourites'
                  : 'Add to favourites',
              onPressed: () async {
                await widget.provider.toggleFavoriteForHymn(widget.hymn.id);
                if (mounted) setState(() {});
              },
            ),
            AdaptiveAppBarAction(
              iosSymbol: 'square.and.arrow.up',
              icon: platformIconData(
                cupertino: CupertinoIcons.share,
                material: Icons.share,
              ),
              label: 'Share',
              onPressed: () => shareHymn(context, widget.hymn),
            ),
          ],
        ),
        body: Builder(
          // The scaffold adds its bars to the padding inside its body.
          builder: (context) {
            final insets = MediaQuery.paddingOf(context);
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _lyrics(context, insets.top, tune),
                      ),
                      // Floats over the lyrics, which scroll under its glass.
                      if (tune != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 8,
                          child: TuneMiniPlayer(tune: tune),
                        ),
                    ],
                  ),
                ),
                SafeArea(top: false, child: const BannerAdWidget()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _lyrics(BuildContext context, double topInset, HymnTune? tune) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        topInset + 16,
        16,
        32 + (tune == null ? 0 : TuneMiniPlayer.height + 8),
      ),
      children: <Widget>[
        Text(
          '${_getHymnCategory()} ${widget.hymn.id}'.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: PlatformInfo.isIOS
                ? CupertinoColors.systemGreen.resolveFrom(context)
                : brandGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.hymn.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            fontFamily: 'Alata',
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Divider(
          height: 24,
          thickness: 1.5,
          indent: 70,
          endIndent: 70,
          color: brandGreen,
        ),
        Consumer<SettingsProvider>(
          builder: (ctx, provider, _) =>
              _getContentWidget(provider.getFontSize().toDouble()),
        ),
      ],
    );
  }
}
