import 'package:baptist_hymnal/List/english_hymn_body.dart';
import 'package:baptist_hymnal/List/english_hymn_list.dart';
import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/screens/english_hymn.dart';
import 'package:flutter/material.dart';

class HymnTile extends StatelessWidget {
  /// hymnKey starts from 1 so to get the corresponding
  /// hymnData we need to subtract 1.. when we use key, we use [hymnKey]
  final int hymnKey;
  final HymnProvider provider;
  const HymnTile(this.hymnKey, this.provider);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: new CircleAvatar(
          backgroundColor: Colors.green.shade300,
          foregroundColor: Colors.white,
          child: Text(
            englishHymnData[hymnKey - 1].hymnNumber.toString(),
            style: TextStyle(fontFamily: 'Alata', fontWeight: FontWeight.w600),
          ),
        ),
        title: new Text(
          englishHymnData[hymnKey - 1].hymnTitle,
          style: TextStyle(
            fontFamily: 'Alata',
          ),
        ),
        trailing: IconButton(
            icon: Icon(
              provider.isEnglishFavorites[hymnKey - 1]
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.pink,
            ),
            onPressed: () => provider.toggleFavoriteAtIndex(hymnKey - 1)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                englishHymnList: englishHymnData[hymnKey - 1],
                englishHymnBody: englishHymnBodyData[hymnKey - 1],
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
