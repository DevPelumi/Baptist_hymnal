import 'package:baptist_hymnal/data/english_hymns.dart';
import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/utils/hymn_helper_functions.dart';
import 'package:baptist_hymnal/widgets/hymn_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Returns a list of favorite Hymns for the english List
/// Uses a Consumer and a ListView builder
class FavoriteEnglishTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EnglishHymnProvider>(
        child: Icon(Icons.directions_transit),
        builder: (ctx, provider, child) => ListView.builder(
              itemBuilder: (ctx, index) => provider.favoritesKeys.isEmpty
                  ? child
                  : HymnTile(
                      HymnHelperFunctions.binSearch(
                          englishHymnData, provider.favoritesKeys[index]),
                      provider),
              itemCount: provider.favoritesKeys.length,
            ));
  }
}
