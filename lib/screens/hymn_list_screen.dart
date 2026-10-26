import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/hymn_provider.dart';
import '../utils/platform_icons.dart';
import '../widgets/hymn_list_item.dart';
import 'search_screen.dart';

/// One book (English, Yoruba or Responsive Reading): a header photo and every
/// hymn in it, with search in the toolbar.
class HymnListScreen<T extends IHymnProvider> extends StatelessWidget {
  const HymnListScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.searchTabIndex,
    this.imageAlignment = Alignment.center,
  });

  final String title;
  final String imagePath;
  final Alignment imageAlignment;

  /// The tab [SearchScreen] opens on for this book.
  final int searchTabIndex;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: title,
        actions: [
          AdaptiveAppBarAction(
            iosSymbol: 'magnifyingglass',
            icon: platformIconData(
              cupertino: CupertinoIcons.search,
              material: Icons.search,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchScreen(initialTabIndex: searchTabIndex),
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return Consumer<T>(
            builder: (context, provider, _) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, insets.top + 12, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        imagePath,
                        height: 160,
                        fit: BoxFit.cover,
                        alignment: imageAlignment,
                      ),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: provider.dataSource.length,
                  itemBuilder: (context, i) => HymnListItem(
                    hymn: provider.dataSource[i],
                    provider: provider,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: insets.bottom + 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
