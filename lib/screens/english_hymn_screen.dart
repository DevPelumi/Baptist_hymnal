import 'package:draggable_scrollbar_sliver/draggable_scrollbar_sliver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/english_hymns.dart';
import '../providers/english_hymn_provider.dart';
import '../widgets/hymn_tile.dart';
import 'search_screen.dart';

class EnglishHymnScreen extends StatefulWidget {
  EnglishHymnScreen({Key key}) : super(key: key);

  @override
  _EnglishHymnScreenState createState() => _EnglishHymnScreenState();
}

class _EnglishHymnScreenState extends State<EnglishHymnScreen> {
  ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableScrollbar.semicircle(
        controller: _scrollController,
        backgroundColor: Colors.green.shade300,
        labelTextBuilder: (pos) => Text(
            '${(pos * englishHymnData.length) ~/ _scrollController.position.maxScrollExtent}'),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => SearchScreen(
                                  initialTabIndex: 0,
                                ))))
              ],
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'English Hymns',
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
                      'assets/images/hymnal2.jpg',
                      fit: BoxFit.cover,
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
            Consumer<EnglishHymnProvider>(
              builder: (ctx, provider, _) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, int i) => HymnTile<EnglishHymnProvider>(
                      provider.dataSource[i], provider),
                  childCount: provider.dataSource.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}
