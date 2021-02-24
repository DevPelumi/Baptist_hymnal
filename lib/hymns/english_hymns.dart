import 'package:flutter/material.dart';
import 'package:baptist_hymnal/List/english_hymn_list.dart';

class HymnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green.shade300,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  itemCount: englishHymnData.length,
                  separatorBuilder: (BuildContext context, int i) =>
                      const Divider(),
                  itemBuilder: (context, int i) => Column(
                    children: [
                      new ListTile(
                        leading: new CircleAvatar(
                            child: Text(englishHymnData[i].hymnNumber.toString())),
                        title: new Text(englishHymnData[i].hymnTitle),
                        onTap: () {},
                        onLongPress: () {
                          print(
                            Text("Long Pressed"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
