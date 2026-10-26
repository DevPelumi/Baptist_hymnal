import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/responsive_reading.dart';
import '../providers/responsive_reading_provider.dart';
import '../widgets/hymn_list_item.dart';
import 'search_screen.dart';

class ResponsiveReading extends StatelessWidget {
  const ResponsiveReading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.green.shade300,
        // Android 15+ draws edge-to-edge: keep rows from scrolling under the
        // status bar, and let the last row scroll clear of the navigation bar.
        body: SafeArea(
            bottom: false,
            child: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                floating: true,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) =>
                                  SearchScreen(initialTabIndex: 2))))
                ],
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    'Responsive Reading',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontFamily: 'Alata',
                        fontWeight: FontWeight.w600),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/hymnal1.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.0, 0.5),
                            end: Alignment(0.0, 0.0),
                            colors: <Color>[
                              Color(0x60000000),
                              Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverSafeArea(
                  top: false,
                  sliver: Consumer<ResponsiveReadingProvider>(
                    builder: (ctx, provider, child) => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, int i) => HymnListItem(
                          hymn: responsive[i],
                          provider: provider,
                        ),
                        childCount: responsive.length,
                      ),
                    ),
                  ))
            ])));
  }
}
