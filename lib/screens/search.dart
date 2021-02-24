import 'package:baptist_hymnal/List/english_hymn_list.dart';
import 'package:baptist_hymnal/List/english_hymn_body.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:flutter/material.dart';

import 'english_hymn.dart';



class HomeSearch extends StatefulWidget {
  @override
  _HomeSearchState createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  BuildContext get index => null;


  Future<List<EnglishHymnList>> _getALlPosts(String text) async {
    await Future.delayed(Duration(seconds: 2));
      return  englishHymnData;
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<EnglishHymnList>(
            onSearch: _getALlPosts,
            onItemFound: (EnglishHymnList EnglishHymnList, int index ) => Card(
              child: ListTile(
                leading: new CircleAvatar(
                  backgroundColor: Colors.green.shade300,
                  foregroundColor: Colors.white,
                  child: Text(
                    EnglishHymnList.hymnNumber.toString(),
                    style: TextStyle(
                        fontFamily: 'Alata', fontWeight: FontWeight.w600),
                  ),
                ),
                title: new Text(
                  EnglishHymnList.hymnTitle,
                  style: TextStyle(
                    fontFamily: 'Alata',
                  ),
                ),
                onTap: () {

                },
                onLongPress: () {
                  print(
                    Text("Long Pressed"),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
