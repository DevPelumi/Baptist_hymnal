import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/platform_icons.dart';

class HymnPlaceholder extends StatelessWidget {
  final String? title;
  const HymnPlaceholder({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              platformIconData(
                cupertino: CupertinoIcons.heart,
                material: Icons.favorite_border,
              ),
              size: 56,
              color: secondary,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'No favourites yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on a hymn to keep it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: secondary),
            ),
          ],
        ),
      ),
    );
  }
}
