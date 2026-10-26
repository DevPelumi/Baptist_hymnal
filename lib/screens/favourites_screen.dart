import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:baptist_hymnal/providers/yoruba_hymn_provider.dart';
import 'package:flutter/material.dart';

import '../providers/english_hymn_provider.dart';
import '../providers/responsive_reading_provider.dart';
import '../widgets/favorite_tab.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  int _book = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Favourites'),
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, insets.top + 8, 16, 8),
                child: AdaptiveSegmentedControl(
                  labels: const ['English', 'Yoruba', 'Reading'],
                  selectedIndex: _book,
                  onValueChanged: (index) => setState(() => _book = index),
                ),
              ),
              Expanded(
                // The segmented control already sits below the toolbar.
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: switch (_book) {
                    1 => const FavoriteTab<YorubaHymnProvider>(),
                    2 => const FavoriteTab<ResponsiveReadingProvider>(),
                    _ => const FavoriteTab<EnglishHymnProvider>(),
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
