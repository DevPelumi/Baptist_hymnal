import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/utils/hymn_helper_functions.dart';
import 'package:baptist_hymnal/widgets/hymn_placeholder.dart';
import 'package:baptist_hymnal/widgets/hymn_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Returns a list of favorite Hymns
/// Uses a Consumer and a ListView builder
class FavoriteTab<T extends IHymnProvider> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      child: HymnPlaceholder(),
      builder: (context, provider, child) {
        if (provider.favoritesKeys.isEmpty) {
          return Container(child: child);
        } else {
          return ListView.builder(
            itemBuilder: (context, index) {
              final hymnIndex = HymnHelperFunctions.binSearch(
                provider.dataSource,
                provider.favoritesKeys[index],
              );
              return HymnTile<T>(hymnIndex!, provider);
            },
            itemCount: provider.favoritesKeys.length,
          );
        }
      },
    );
  }
}
