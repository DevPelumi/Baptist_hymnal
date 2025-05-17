import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/hymn_data.dart';
import '../providers/hymn_provider.dart';
import '../screens/details_screen.dart';

class HymnListItem extends StatelessWidget {
  final HymnData hymn;
  final IHymnProvider provider;
  final bool showFavorite;

  const HymnListItem({
    Key? key,
    required this.hymn,
    required this.provider,
    this.showFavorite = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = provider.isFavorite(hymn.id);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.all(10),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                hymn: hymn,
                provider: provider,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  hymn.id.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                hymn.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            if (showFavorite && isFavorite)
              Icon(
                CupertinoIcons.bookmark_fill,
                color: CupertinoColors.systemRed.resolveFrom(context),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
