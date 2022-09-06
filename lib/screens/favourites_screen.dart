import 'package:baptist_hymnal/providers/yoruba_hymn_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../providers/english_hymn_provider.dart';
import '../providers/responsive_reading_provider.dart';
import '../widgets/favorite_english_tab.dart';

const style = TextStyle(
  fontFamily: 'Alata',
  fontSize: 25,
  fontWeight: FontWeight.w600,
  color: Colors.white,
  letterSpacing: 1.2,
);

class Favourites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink.shade300,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontFamily: 'Alata'),
            tabs: [
              Tab(text: 'English Hymns'),
              Tab(text: 'Yoruba Hymns'),
              Tab(text: 'Reading'),
            ],
          ),
          title: Text(
            'Favorites',
            style: style,
          ),
        ),
        body: TabBarView(
          children: [
            FavoriteTab<EnglishHymnProvider>(),
            FavoriteTab<YorubaHymnProvider>(),
            FavoriteTab<ResponsiveReadingProvider>(),
          ],
        ),
      ),
    );
  }
}
