import 'package:flutter/material.dart';
import 'package:cuberto_bottom_bar/cuberto_bottom_bar.dart';
import 'screens/homescreen.dart';
import 'screens/Settings.dart';
import 'screens/favourites.dart';
import 'screens/search.dart';
import 'hymns/Hymn1.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int currentPage;
  Color currentColor = Colors.deepPurple;
  Color inactiveColor = Colors.black;
  TabController tabBarController;
  List<Tabs> tabs = new List();

  int selectedIndex = 0;
  int _selectedPage = 0;

  final _pageOptions = [
    HomeScreen(),
    Favourites(),
    HomeSearch(),
    Settings(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = 0;
    tabs.add(Tabs(Icons.home, "Home", Colors.green.shade300));
    tabs.add(Tabs(Icons.favorite, "Liked", Colors.pink));
    tabs.add(Tabs(Icons.search, "Search", Colors.blueAccent));
    tabs.add(Tabs(Icons.settings, "Settings", Colors.teal));
    tabBarController =
        new TabController(initialIndex: _selectedPage, length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: TabBarView(
          controller: tabBarController,
          physics: NeverScrollableScrollPhysics(),
          children: {2, 3, 1, 0}
              .map(
                (index) => _pageOptions[_selectedPage],
              )
              .toList()),

      /**drawer: new Container(
          width: 250.0,
          margin: EdgeInsets.only(bottom: 60.0),
          color: Colors.blue,
          child: ListView(
            children: <Widget>[Text("Hello"), Text("World")],
          )),
      endDrawer: new Container(
          width: 250.0,
          margin: EdgeInsets.only(bottom: 60.0),
          color: Colors.blue,
          child: ListView(
            children: <Widget>[Text("Hello"), Text("World")],
          )),**/

      bottomNavigationBar: CubertoBottomBar(
        inactiveIconColor: inactiveColor,
        tabStyle: CubertoTabStyle.STYLE_FADED_BACKGROUND,
        selectedTab: _selectedPage,

        /// initial Selection has been renames to selectedTab, setting the index value to this will change the tab
        tabs: tabs
            .map((value) => TabData(
                  iconData: value.icon,
                  title: value.title,
                  tabColor: value.color,
                ))
            .toList(),
        onTabChangedListener: (index, title, color) {
          setState(() {
            tabBarController.animateTo(index);

            _selectedPage = index;
          });
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }
}

class Tabs {
  final IconData icon;
  final String title;
  final Color color;

  Tabs(this.icon, this.title, this.color);
}
