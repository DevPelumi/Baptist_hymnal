import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/utils/hymn_helper_functions.dart';
import 'package:baptist_hymnal/widgets/hymn_placeholder.dart';
import 'package:baptist_hymnal/widgets/hymn_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteTab<T extends IHymnProvider> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (ctx, provider, _) => provider.favoritesKeys.isEmpty
          ? HymnPlaceholder()
          : ListView.builder(
              itemBuilder: (ctx, index) {
                final hymn = HymnHelperFunctions.binSearch(
                    provider.dataSource, provider.favoritesKeys[index]);
                if (hymn == null) return const SizedBox.shrink();
                return HymnListItem(
                  hymn: hymn,
                  provider: provider,
                );
              },
              itemCount: provider.favoritesKeys.length,
            ),
    );
  }
}
