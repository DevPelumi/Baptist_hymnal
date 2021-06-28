import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/favourites_screen.dart';
import 'package:splashscreen/splashscreen.dart';
import 'screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:cuberto_bottom_bar/cuberto_bottom_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(child: FirstScreen(), providers: [
      ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(), lazy: true),
      ChangeNotifierProvider<EnglishHymnProvider>(
          create: (_) => EnglishHymnProvider(), lazy: true)
    ]);
  }
}

class FirstScreen extends StatelessWidget {
  SettingsProvider _settingsProvider;
  EnglishHymnProvider _englishHymn;
  FirstScreen({Key key}) : super(key: key);
  Future<Widget> _initProviders(BuildContext context) async {
    _settingsProvider = context.read<SettingsProvider>();
    await _settingsProvider.fetchSettings();

    _englishHymn = context.read<EnglishHymnProvider>();
    await _englishHymn.fetchFavorites();

    return MyHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Baptist Hymn',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: context.watch<SettingsProvider>().isDarkMode(
                SchedulerBinding.instance.window.platformBrightness ==
                    Brightness.dark)
            ? ThemeMode.dark
            : ThemeMode.light,
        home: SplashScreen(
          loadingText: Text('Fetching Hymns...'),
          backgroundColor: Colors.green.shade300,
          seconds: 2,
          navigateAfterSeconds: MyHomePage(),
          navigateAfterFuture: _initProviders(context),
          title: Text('Baptist Hymnal',
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alata',
                  fontSize: 20.0)),
        ));
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
  TabController tabBarController;
  List<Tabs> tabs = [];

  int _selectedPage = 0;

  final _pageOptions = [
    HomeScreen(),
    Favourites(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
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
    return Scaffold(
      body: TabBarView(
          controller: tabBarController,
          physics: NeverScrollableScrollPhysics(),
          children: _pageOptions),
      bottomNavigationBar: CubertoBottomBar(
        inactiveIconColor: Theme.of(context).iconTheme.color,
        tabStyle: CubertoTabStyle.STYLE_FADED_BACKGROUND,
        selectedTab: _selectedPage,
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
      ),
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
