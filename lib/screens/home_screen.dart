import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../providers/english_hymn_provider.dart';
import '../purchases/premium.dart';
import '../purchases/upgrade_prompt.dart';
import '../utils/platform_icons.dart';
import 'remove_ads_screen.dart';
import '../providers/responsive_reading_provider.dart';
import '../providers/yoruba_hymn_provider.dart';
import '../utils/responsive.dart';
import 'hymn_list_screen.dart';
import '../widgets/duo_tab_bar.dart';
import '../utils/app_font.dart';

/// A screen that displays the main navigation options for the Baptist Hymnal app.
/// It provides access to English Hymns, Yoruba Hymns, and Responsive Reading sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = [
    HymnCategory(
      title: 'English Hymns',
      imagePath: 'assets/images/hymnal2.jpg',
      screen: HymnListScreen<EnglishHymnProvider>(
        title: 'English Hymns',
        imagePath: 'assets/images/hymnal2.jpg',
        searchTabIndex: 0,
      ),
    ),
    HymnCategory(
      title: 'Responsive Reading',
      imagePath: 'assets/images/hymnal1.jpg',
      screen: HymnListScreen<ResponsiveReadingProvider>(
        title: 'Responsive Reading',
        imagePath: 'assets/images/hymnal1.jpg',
        imageAlignment: Alignment.bottomCenter,
        searchTabIndex: 2,
      ),
    ),
    HymnCategory(
      title: 'Yoruba Hymns',
      imagePath: 'assets/images/hymnal3.jpg',
      screen: HymnListScreen<YorubaHymnProvider>(
        title: 'Yoruba Hymns',
        imagePath: 'assets/images/hymnal3.jpg',
        searchTabIndex: 1,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Baptist Hymnal'),
      bottomNavigationBar: DuoTabBar.of(context),
      body: AppFont(
        child: Builder(
          // The scaffold adds its bars to the padding inside its body.
          builder: (context) {
            final insets = MediaQuery.paddingOf(context);
            final columns = Responsive.columns(context);
            final cards = [
              for (final category in _categories) _HymnCard(category: category),
            ];
            return ListView(
              // The bars float over the page on iOS 26, so pad by their insets.
              padding: EdgeInsets.fromLTRB(
                16,
                insets.top + 12 + DuoTabBar.titleFadeClearance(context),
                16,
                insets.bottom + 16,
              ),
              children: [
                ...switch (columns) {
                  // A phone: one book per row.
                  1 => [for (final card in cards) _sized(card, 180)],
                  // A tablet in portrait or an unfolded phone: English, the
                  // most used, across the top, and the other two beside each
                  // other.
                  2 => [
                    _sized(cards.first, 220),
                    _row(cards.skip(1).toList(), 220),
                  ],
                  // A wide tablet: all three side by side.
                  _ => [_row(cards, 240)],
                },
                // Below the books, so it never pushes them down.
                const _UpgradeCard(),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _sized(Widget card, double height) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: SizedBox(height: height, child: card),
);

Widget _row(List<Widget> cards, double height) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: SizedBox(
    height: height,
    child: Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: cards[i]),
        ],
      ],
    ),
  ),
);

/// A model class representing a hymn category with its properties.
class HymnCategory {
  final String title;
  final String imagePath;
  final Widget screen;

  const HymnCategory({
    required this.title,
    required this.imagePath,
    required this.screen,
  });
}

/// A card widget that displays a hymn category with an image and title.
class _HymnCard extends StatelessWidget {
  final HymnCategory category;

  const _HymnCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.title,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => category.screen),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            image: DecorationImage(
              colorFilter: const ColorFilter.mode(
                Colors.black26,
                BlendMode.darken,
              ),
              fit: BoxFit.cover,
              image: AssetImage(category.imagePath),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          // Shrinks rather than wraps in a narrow card.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Text(
              category.title,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Alata',
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Offers Premium once the user knows the app, until they buy it or choose
/// Not Now (see [UpgradePrompt]). Hidden while there's nothing to sell.
class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        UpgradePrompt.isDue,
        Premium.hasPlans,
        Premium.isActive,
      ]),
      builder: (context, _) {
        if (!UpgradePrompt.isDue.value ||
            !Premium.hasPlans.value ||
            Premium.isActive.value) {
          return const SizedBox.shrink();
        }
        final ios = PlatformInfo.isIOS;
        final scheme = Theme.of(context).colorScheme;
        final accent = ios
            ? CupertinoColors.systemGreen.resolveFrom(context)
            : scheme.primary;
        final label = ios
            ? CupertinoColors.label.resolveFrom(context)
            : scheme.onSurface;
        final secondaryLabel = ios
            ? CupertinoColors.secondaryLabel.resolveFrom(context)
            : scheme.onSurfaceVariant;
        final radius = BorderRadius.circular(22);
        return Material(
          color: ios
              ? accent.withValues(alpha: 0.12)
              : scheme.secondaryContainer,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: () => showRemoveAds(context, source: 'home'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(
                        platformIconData(
                          cupertino: CupertinoIcons.sparkles,
                          material: Icons.auto_awesome,
                        ),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enjoy an ad-free experience',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: label,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Monthly, yearly or pay once',
                          style: TextStyle(fontSize: 14, color: secondaryLabel),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Not now',
                    onPressed: UpgradePrompt.dismiss,
                    icon: Icon(
                      platformIconData(
                        cupertino: CupertinoIcons.xmark,
                        material: Icons.close,
                      ),
                      size: 18,
                      color: secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
