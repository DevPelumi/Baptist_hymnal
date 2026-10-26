import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../providers/english_hymn_provider.dart';
import '../providers/responsive_reading_provider.dart';
import '../providers/yoruba_hymn_provider.dart';
import 'hymn_list_screen.dart';

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
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return ListView(
            // The bars float over the page on iOS 26, so pad by their insets.
            padding: EdgeInsets.fromLTRB(
              16,
              insets.top + 12,
              16,
              insets.bottom + 16,
            ),
            children: [
              for (final category in _categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _HymnCard(category: category),
                ),
            ],
          );
        },
      ),
    );
  }
}

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
          height: 180,
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
          child: Text(
            category.title,
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
    );
  }
}
