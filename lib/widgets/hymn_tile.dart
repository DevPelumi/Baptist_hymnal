import 'package:baptist_hymnal/models/hymn_data.dart';
import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/screens/english_hymn_screen.dart';
import 'package:flutter/material.dart';

class HymnTile extends StatelessWidget {
  /// hymnKey starts from 1 so to get the corresponding
  /// hymnData we need to subtract 1.. when we use key, we use [hymnKey]
  final HymnData hymnData;
  final EnglishHymnProvider provider;
  final bool showFavorites;
  const HymnTile(this.hymnData, this.provider, {this.showFavorites = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: new CircleAvatar(
          backgroundColor: Colors.green.shade300,
          foregroundColor: Colors.white,
          child: Text(
            hymnData.id.toString(),
            style: TextStyle(fontFamily: 'Alata', fontWeight: FontWeight.w600),
          ),
        ),
        title: new Text(
          hymnData.title,
          style: TextStyle(
            fontFamily: 'Alata',
          ),
        ),
        trailing: showFavorites
            ? IconButton(
                icon: Icon(
                  provider.isFavorite(hymnData.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.pink,
                ),
                onPressed: () => provider.toggleFavoriteForHymn(hymnData.id))
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                hymn: hymnData,
              ),
            ),
          );
        },
        onLongPress: () {
          print(
            Text("Long Pressed"),
          );
        },
      ),
    );
  }
}
