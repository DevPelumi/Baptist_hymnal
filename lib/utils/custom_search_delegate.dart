import 'package:flutter/material.dart';

class CustomSearchDelegate<T> extends SearchDelegate {
  final Widget Function(BuildContext, T, int) itemBuilder;
  final List<T> Function(String) itemFilter;
  final PreferredSizeWidget? bottom;
  CustomSearchDelegate({
    required this.itemBuilder,
    required this.itemFilter,
    this.bottom,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final items = itemFilter(query);
    return ListView.builder(
        itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
        itemCount: items.length);
  }

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    return bottom;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final items = itemFilter(query);
    return ListView.builder(
        itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
        itemCount: items.length);
  }
}
