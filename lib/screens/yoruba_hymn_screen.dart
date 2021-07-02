import 'package:flutter/material.dart';

import '../data/yoruba_hymns.dart';

class YorubaHymnScreen extends StatelessWidget {
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
                'Yoruba Hymns',
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, int i) => Card(
                child: ListTile(
                  leading: new CircleAvatar(
                      backgroundColor: Colors.green.shade300,
                      foregroundColor: Colors.white,
                      child: Text(
                        yorubaHymnData[i].id.toString(),
                        style: TextStyle(
                            fontFamily: 'Alata', fontWeight: FontWeight.w600),
                      )),
                  title: new Text(
                    yorubaHymnData[i].title,
                    style: TextStyle(
                      fontFamily: 'Alata',
                    ),
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.pink,
                      ),
                      onPressed: null),
                  onTap: () {},
                  onLongPress: () {
                    print(
                      Text("Long Pressed"),
                    );
                  },
                ),
              ),
              childCount: yorubaHymnData.length,
            ),
          ),
          SliverToBoxAdapter(
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
                        child: Icon(Icons.auto_stories,
                          size: 70,
                          color: const Color(0xFF81C784) ,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text('Coming Soon!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Alata',
                      fontSize:22,)
                    ,)
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
