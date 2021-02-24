import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/widgets/hymn_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Returns a list of favorite Hymns for the english List
/// Uses a Consumer and a ListView builder
class FavoriteEnglish extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HymnProvider>(
        child: Icon(Icons.directions_transit),
        builder: (ctx, provider, child) => ListView.builder(
              itemBuilder: (ctx, index) => provider.englishFavoritesKey.isEmpty
                  ? child
                  : HymnTile(provider.englishFavoritesKey[index], provider),
              itemCount: provider.englishFavoritesKey.length,
            ));
  }
}
