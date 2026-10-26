import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/hymn_data.dart';
import '../providers/hymn_provider.dart';
import '../screens/details_screen.dart';
import '../utils/platform_icons.dart';

class HymnListItem extends StatelessWidget {
  final HymnData hymn;
  final IHymnProvider provider;
  final bool showFavorite;

  const HymnListItem({
    super.key,
    required this.hymn,
    required this.provider,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = provider.isFavorite(hymn.id);

    return AdaptiveListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: brandGreen,
          shape: BoxShape.circle,
        ),
        child: Text(
          hymn.id.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(hymn.title),
      trailing: showFavorite && isFavorite
          ? Icon(
              platformIconData(
                cupertino: CupertinoIcons.heart_fill,
                material: Icons.favorite,
              ),
              color: CupertinoColors.systemPink.resolveFrom(context),
              size: 20,
            )
          : null,
      onTap: () {
        // Otherwise the search field takes focus back, and the keyboard
        // with it, when the user returns from the hymn.
        FocusScope.of(context).unfocus();
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
    );
  }
}
