import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/providers/responsive_reading_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../models/hymn_data.dart';
import '../providers/hymn_provider.dart';
import '../providers/settings_provider.dart';

const textStyle = TextStyle(fontFamily: 'Alata', fontWeight: FontWeight.w600);

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final HymnData hymn;
  final IHymnProvider provider;
  // In the constructor, require a Todo.
  DetailScreen({Key key, @required this.hymn, @required this.provider})
      : super(key: key);
  Widget _getContentWidget(double fontSize) {
    if (provider is ResponsiveReadingProvider) {
      int counter = 0;
      return Column(
          children: hymn.contents
              .map(
                (t) => Text(t + '\n',
                    style: TextStyle(
                        fontSize: fontSize,
                        fontFamily: 'Alata',
                        fontStyle: counter % 2 == 0
                            ? FontStyle.normal
                            : FontStyle.italic,
                        fontWeight: (counter++) % 2 == 0
                            ? FontWeight.bold
                            : FontWeight.normal)),
              )
              .toList());
    } else
      return Text(
        hymn.contents.join("\n"),
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Alata',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
          IconButton(
              onPressed: () => provider.toggleFavoriteForHymn(hymn.id),
              icon: Icon(
                  provider.isFavorite(hymn.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.pink)),
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
                  builder: (ctx, provider, _) =>
                      _getContentWidget(provider.getFontSize().toDouble())),
            ),
          ],
        ),
      ),
    );
  }
}
