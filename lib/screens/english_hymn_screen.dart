import 'package:baptist_hymnal/models/hymn_data.dart';
import 'package:baptist_hymnal/providers/settings_provider.dart';
import 'package:baptist_hymnal/screens/search_screen.dart';
import 'package:draggable_scrollbar_sliver/draggable_scrollbar_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../data/english_hymns.dart';
import '../providers/english_hymn_provider.dart';
import '../widgets/hymn_tile.dart';

const textStyle = TextStyle(fontFamily: 'Alata', fontWeight: FontWeight.w600);

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
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (ctx) =>
                                SearchScreen(list: [...englishHymnData]))))
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
                  (context, int i) => HymnTile(englishHymnData[i], provider),
                  childCount: englishHymnData.length,
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

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final HymnData hymn;

  // In the constructor, require a Todo.
  DetailScreen({Key key, @required this.hymn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // A builder is used to retrieve the context immediately
          // surrounding the RaisedButton.
          //
          // The context's `findRenderObject` returns the first
          // RenderObject in its descendent tree when it's not
          // a RenderObjectWidget. The RaisedButton's RenderObject
          // has its position and size after it's built.
          final RenderBox box = context.findRenderObject();
          Share.share(
              hymn.title +
                  '\n' +
                  hymn.contents.join("\n") +
                  '\n' +
                  "DOWNLOAD FROM PLAYSTORE",
              subject: 'Share Hymn',
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        },
        child: Icon(Icons.share),
      ),
      appBar: AppBar(
        elevation: 13,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                hymn.id.toString(),
                style: textStyle,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              width: 160,
              child: Text(
                hymn.title,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Consumer<EnglishHymnProvider>(
            builder: (ctx, provider, _) => IconButton(
                onPressed: () => provider.toggleFavoriteForHymn(hymn.id),
                icon: Icon(
                    provider.isFavorite(hymn.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.pink)),
          ),
          IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: null)
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    hymn.title,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Alata',
                    ),
                  )),
                ),
                Center(
                    child: Divider(
                  thickness: 1.5,
                  indent: 70,
                  endIndent: 70,
                  color: Colors.green.shade300,
                )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 55),
              child: Consumer<SettingsProvider>(
                builder: (ctx, provider, _) => Text(
                  hymn.contents.join("\n"),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: provider.getFontSize().toDouble(),
                    fontFamily: 'Alata',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
