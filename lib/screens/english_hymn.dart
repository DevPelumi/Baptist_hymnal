import 'package:baptist_hymnal/providers/hymn_provider.dart';
import 'package:baptist_hymnal/widgets/hymn_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar_sliver/draggable_scrollbar_sliver.dart';
import 'package:baptist_hymnal/List/english_hymn_list.dart';
import 'package:baptist_hymnal/List/english_hymn_body.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

const textStyle = TextStyle(fontFamily: 'Alata', fontWeight: FontWeight.w600);

class EnglishHymns extends StatelessWidget {
  final List<Todo> todos;

  EnglishHymns({Key key, @required this.todos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.green.shade300,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: null)
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
          Consumer<HymnProvider>(
            builder: (ctx, provider, _) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, int i) => HymnTile(i + 1,provider),
                childCount: englishHymnData.length,
              ),
            ),
          )
        ],
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
  final EnglishHymnList englishHymnList;
  final EnglishHymnBody englishHymnBody;

  // In the constructor, require a Todo.
  DetailScreen({Key key, this.englishHymnList, this.englishHymnBody})
      : super(key: key);

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
              englishHymnList.hymnTitle +
                  '\n' +
                  englishHymnBody.hymnContent +
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
                englishHymnList.hymnNumber.toString(),
                style: textStyle,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              width: 180,
              child: Text(
                englishHymnList.hymnTitle,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: <Widget>[
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
                    englishHymnList.hymnTitle,
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
              child: Text(
                englishHymnBody.hymnContent,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Alata',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
