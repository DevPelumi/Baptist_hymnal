import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'english_hymn_screen.dart';
import 'responsive_reading_screen.dart';
import 'yoruba_hymn_screen.dart';

/// A screen that displays the main navigation options for the Baptist Hymnal app.
/// It provides access to English Hymns, Yoruba Hymns, and Responsive Reading sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _animationDuration = Duration(milliseconds: 500);
  static const _horizontalOffset = 50.0;
  static const _cardHeight = 200.0;
  static const _borderRadius = 16.0;
  static const _shadowOffset = Offset(8, 10);
  static const _shadowBlur = 20.0;

  final List<HymnCategory> _categories = [
    HymnCategory(
      title: 'English Hymns',
      imagePath: 'assets/images/hymnal2.jpg',
      screen: EnglishHymnScreen(),
    ),
    HymnCategory(
      title: 'Responsive Reading',
      imagePath: 'assets/images/hymnal1.jpg',
      screen: ResponsiveReading(),
    ),
    HymnCategory(
      title: 'Yoruba Hymns',
      imagePath: 'assets/images/hymnal3.jpg',
      screen: YorubaHymnScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade300,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: _animationDuration,
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: _horizontalOffset,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    ..._categories.map((category) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HymnCard(category: category),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(15.0),
      child: Text(
        'BAPTIST HYMNAL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontFamily: 'Alata',
          fontWeight: FontWeight.w600,
        ),
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

  const _HymnCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => category.screen),
      ),
      child: Stack(
        children: [
          Container(
            height: _HomeScreenState._cardHeight,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(_HomeScreenState._borderRadius),
              color: Colors.blue,
              image: DecorationImage(
                colorFilter: const ColorFilter.mode(
                  Colors.black26,
                  BlendMode.darken,
                ),
                fit: BoxFit.cover,
                image: AssetImage(category.imagePath),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: _HomeScreenState._shadowOffset,
                  blurRadius: _HomeScreenState._shadowBlur,
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            bottom: 20,
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
        ],
      ),
    );
  }
}
