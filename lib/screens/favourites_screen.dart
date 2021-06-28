import 'package:baptist_hymnal/widgets/favorite_english_tab.dart';
import 'package:flutter/material.dart';

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
            FavoriteEnglishTab(),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}
