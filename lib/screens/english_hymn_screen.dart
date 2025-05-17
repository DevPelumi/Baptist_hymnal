import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/english_hymns.dart';
import '../providers/english_hymn_provider.dart';
import '../widgets/hymn_list_item.dart';
import 'search_screen.dart';

class EnglishHymnScreen extends StatefulWidget {
  const EnglishHymnScreen({super.key});

  @override
  _EnglishHymnScreenState createState() => _EnglishHymnScreenState();
}

class _EnglishHymnScreenState extends State<EnglishHymnScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              iconTheme: IconThemeData(color: Colors.white),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => SearchScreen(
                      initialTabIndex: 0,
                    ),
                  )),
                )
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
                    fontWeight: FontWeight.w600,
                  ),
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
                  (context, int i) => HymnListItem(
                    hymn: provider.dataSource[i],
                    provider: provider,
                  ),
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
