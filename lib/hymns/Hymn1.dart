import 'package:baptist_hymnal/List/english_hymn_list.dart';
import 'package:flutter/material.dart';
import 'package:baptist_hymnal/screens/english_hymn.dart';
import 'package:baptist_hymnal/screens/yoruba_hymn.dart';
import 'package:baptist_hymnal/screens/responsive_reading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


const longString = '''

1
Holy, holy, holy! Lord God Almighty!
Early in the morning our song shall rise to thee.
Holy, holy, holy! Merciful and mighty!
God in three Persons, blessed Trinity!

2 
Holy, holy, holy! All the saints adore thee,
casting down their golden crowns around the glassy sea;
cherubim and seraphim falling down before thee,
who wert, and art, and evermore shalt be.

3 
Holy, holy, holy! Though the darkness hide thee,
though the eye of sinful man thy glory may not see,
only thou art holy; there is none beside thee
perfect in pow'r, in love, and purity.

4
Holy, holy, holy! Lord God Almighty!
All thy works shall praise thy name in earth and sky and sea.
Holy, holy, holy! Merciful and mighty!
God in three Persons, blessed Trinity!
''';

class Hymn1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 1375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'BAPTIST HYMNAL',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontFamily: 'Alata',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Stack(children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EnglishHymns()),
                              );
                            },
                            child: Container(
                              height: 220,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colors.blue,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      'assets/images/hymnal2.jpg',
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        offset: Offset(
                                          8,
                                          10,
                                        ),
                                        blurRadius: 20.0)
                                  ]),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            bottom: 20,
                            child: Text(
                              'English Hymns',
                              style: TextStyle(
                                fontFamily: 'Alata',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => YorubaHymns()),
                            );
                          },
                          child: Stack(children: <Widget>[
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colors.blue,
                                  image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                        Colors.black26, BlendMode.darken),
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      'assets/images/hymnal3.jpg',
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        offset: Offset(
                                          8,
                                          10,
                                        ),
                                        blurRadius: 20.0)
                                  ]),
                            ),
                            Positioned(
                              left: 24,
                              bottom: 20,
                              child: Text(
                                'Yoruba Hymns',
                                style: TextStyle(
                                  fontFamily: 'Alata',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            )
                          ]),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ResponsiveReading()));
                          },
                          child: Stack(children: <Widget>[
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colors.blue,
                                  image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                        Colors.black26, BlendMode.darken),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                    image: AssetImage(
                                      'assets/images/hymnal1.jpg',
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        offset: Offset(
                                          8,
                                          10,
                                        ),
                                        blurRadius: 20.0)
                                  ]),
                            ),
                            Positioned(
                              left: 24,
                              bottom: 20,
                              child: Text(
                                'Resonsive Reading',
                                style: TextStyle(
                                  fontFamily: 'Alata',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final text = 'Holy, Holy, Holy, Lord God Almighty!\n'
    ' Unto everlasting days our song shall rise to Thee;\n'
    ' Holy, Holy, Holy, Merciful and Mighty!\n'
    ' God in Three Persons, blessed Trinity!\n';
