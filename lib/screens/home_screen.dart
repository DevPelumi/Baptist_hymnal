import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'english_hymn_screen.dart';
import 'responsive_reading_screen.dart';
import 'yoruba_hymn_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final hymnalCategory = ['English Hymnal', 'Yoruba Hymnal', 'Reading'];

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade300,
      body: ListView(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 1000),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
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
                          MaterialPageRoute(
                              builder: (context) => EnglishHymnScreen()),
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
                        MaterialPageRoute(
                            builder: (context) => YorubaHymnScreen()),
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
                          'Responsive Reading',
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
        )
      ]),
    );
  }
}
