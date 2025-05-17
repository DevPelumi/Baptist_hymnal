import 'package:baptist_hymnal/providers/responsive_reading_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import "package:baptist_hymnal/ad_helper.dart";
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/hymn_data.dart';
import '../providers/hymn_provider.dart';
import '../providers/settings_provider.dart';

const textStyle = TextStyle(
    fontFamily: 'Alata', fontWeight: FontWeight.w600, color: Colors.black);

class DetailScreen extends StatefulWidget {
  // Declare a field that holds the Todo.
  final HymnData hymn;
  final IHymnProvider provider;
  // In the constructor, require a Todo.
  DetailScreen({
    super.key,
    required this.hymn,
    required this.provider,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Widget _getContentWidget(double fontSize) {
    if (widget.provider is ResponsiveReadingProvider) {
      int counter = 0;
      return Column(
          children: widget.hymn.contents
              .map(
                (t) => Text(t + '\n',
                    style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'Alata',
                        fontStyle: counter % 2 == 0
                            ? FontStyle.normal
                            : FontStyle.italic,
                        fontWeight: (counter++) % 2 == 0
                            ? FontWeight.bold
                            : FontWeight.normal)),
              )
              .toList());
    } else
      return Text(
        widget.hymn.contents.join("\n"),
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Alata',
        ),
      );
  }

  void _navigateToHymn(HymnData hymn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          hymn: hymn,
          provider: widget.provider,
        ),
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
    AdHelper.loadBannerAd();
    AdHelper.loadInterstitialAd();
  }

  @override
  void dispose() {
    AdHelper.disposeBannerAd();
    AdHelper.disposeInterstitialAd();
    super.dispose();
  }

  Widget _buildAdWidget() {
    if (AdHelper.myBanner == null) {
      return const SizedBox.shrink();
    }
    return AdWidget(ad: AdHelper.myBanner!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AdHelper.incrementHymnViewCount();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.green.shade500,
          onPressed: () {
            final RenderBox? box = context.findRenderObject() as RenderBox?;
            if (box != null) {
              Share.share(
                widget.hymn.title +
                    '\n' +
                    widget.hymn.contents.join("\n") +
                    '\n\n' +
                    "📱 Baptist Hymnal App\n" +
                    "Download from Play Store",
                subject: 'Share Hymn',
                sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
              );
            }
          },
          child: const Icon(Icons.share, color: Colors.white),
        ),
        appBar: AppBar(
          elevation: 13,
          backgroundColor: Colors.green.shade400,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              AdHelper.incrementHymnViewCount();
              Navigator.pop(context);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  widget.hymn.id.toString(),
                  style: textStyle,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                final prevHymn = _getPreviousHymn();
                if (prevHymn != null) {
                  _navigateToHymn(prevHymn);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () {
                final nextHymn = _getNextHymn();
                if (nextHymn != null) {
                  _navigateToHymn(nextHymn);
                }
              },
            ),
            IconButton(
              onPressed: () =>
                  widget.provider.toggleFavoriteForHymn(widget.hymn.id),
              icon: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                  child: Icon(
                      widget.provider.isFavorite(widget.hymn.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      widget.hymn.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Alata',
                      ),
                    )),
                  ),
                  Center(
                      child: Divider(
                    thickness: 1.5,
                    indent: 70,
                    endIndent: 70,
                    color: Colors.green.shade300,
                  )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 55),
                child: Consumer<SettingsProvider>(
                    builder: (ctx, provider, _) =>
                        _getContentWidget(provider.getFontSize().toDouble())),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 50,
          color: Colors.green,
          child: _buildAdWidget(),
        ),
      ),
    );
  }
}
