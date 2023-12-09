import 'package:flutter/material.dart';

class CustomSearchDelegate<T> extends SearchDelegate {
  final Widget Function(BuildContext, T, int)? itemBuilder;
  final List<T> Function(String)? itemFilter;
  final PreferredSizeWidget? bottom;

  CustomSearchDelegate({
    @required this.itemBuilder,
    @required this.itemFilter,
    this.bottom,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Return a list of widget actions, if any
    return null;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Return the leading widget, if any
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    final items = itemFilter?.call(query) ?? [];
    return ListView.builder(
      itemBuilder: (ctx, i) => itemBuilder?.call(ctx, items[i], i) ?? Container(),
      itemCount: items.length,
    );
  }

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    // Return the bottom widget, if any
    return bottom;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final items = itemFilter?.call(query) ?? [];
    return ListView.builder(
      itemBuilder: (ctx, i) => itemBuilder?.call(ctx, items[i], i) ?? Container(),
      itemCount: items.length,
    );
  }
}
