import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/yoruba_hymns.dart';
import '../providers/yoruba_hymn_provider.dart';
import '../widgets/hymn_list_item.dart';
import 'search_screen.dart';

class YorubaHymnScreen extends StatefulWidget {
  const YorubaHymnScreen({super.key});

  @override
  _YorubaHymnScreenState createState() => _YorubaHymnScreenState();
}

class _YorubaHymnScreenState extends State<YorubaHymnScreen> {
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
                      initialTabIndex: 1,
                    ),
                  )),
                )
              ],
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Yoruba Hymns',
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
                      'assets/images/hymnal3.jpg',
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
            Consumer<YorubaHymnProvider>(
              builder: (context, provider, _) {
                if (provider.dataSource.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              height: 180.0,
                              width: 180.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.shade100,
                              ),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.auto_stories,
                                  size: 70,
                                  color: const Color(0xFF81C784),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            'Coming Soon!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Alata',
                              fontSize: 22,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, int i) => HymnListItem(
                      hymn: provider.dataSource[i],
                      provider: provider,
                    ),
                    childCount: provider.dataSource.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
