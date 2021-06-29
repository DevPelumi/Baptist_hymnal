import 'package:baptist_hymnal/models/hymn_data.dart';
import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/screens/details_screen.dart';
import 'package:flutter/material.dart';

class HymnTile<T extends IHymnProvider> extends StatelessWidget {
  final HymnData hymnData;
  final T provider;
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
                provider: provider,
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
