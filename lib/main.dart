import 'package:baptist_hymnal/providers/english_hymn_provider.dart';
import 'package:baptist_hymnal/providers/responsive_reading_provider.dart';
import 'package:baptist_hymnal/providers/settings_provider.dart';
import 'package:baptist_hymnal/providers/yoruba_hymn_provider.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/search_screen.dart';
import 'utils/platform_icons.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'ad_helper.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['Fluid R3 SoundFont (hymn tune piano)'],
      await rootBundle.loadString('assets/soundfonts/FLUID_R3_LICENSE.txt'),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider<EnglishHymnProvider>(
          create: (_) => EnglishHymnProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => YorubaHymnProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => ResponsiveReadingProvider(),
          lazy: true,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final isDark = settingsProvider.isDarkMode(
              MediaQuery.platformBrightnessOf(context) == Brightness.dark);
          final lightTheme = ThemeData(
            colorSchemeSeed: brandGreen,
            brightness: Brightness.light,
          );
          final darkTheme = ThemeData(
            colorSchemeSeed: brandGreen,
            brightness: Brightness.dark,
          );
          // iOS gets a CupertinoApp with native bars; Material on Android.
          return AdaptiveApp(
            title: 'Baptist Hymnal',
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            materialLightTheme: lightTheme,
            materialDarkTheme: darkTheme,
            cupertinoLightTheme: const CupertinoThemeData(
              brightness: Brightness.light,
              primaryColor: CupertinoColors.systemGreen,
            ),
            cupertinoDarkTheme: const CupertinoThemeData(
              brightness: Brightness.dark,
              primaryColor: CupertinoColors.systemGreen,
            ),
            // The CupertinoApp on iOS has no Material theme or localizations,
            // which the hymn text, tune bar and licence page still use.
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            builder: (context, child) => PlatformInfo.isIOS
                ? Theme(data: isDark ? darkTheme : lightTheme, child: child!)
                : child!,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
            home: const FirstScreen(),
          );
        },
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeAppAndProviders();
  }

  Future<void> _initializeAppAndProviders() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final englishHymn =
        Provider.of<EnglishHymnProvider>(context, listen: false);
    final responsive =
        Provider.of<ResponsiveReadingProvider>(context, listen: false);
    final yorubaHymn = Provider.of<YorubaHymnProvider>(context, listen: false);

    await Future.wait([
      settingsProvider.fetchSettings(),
      englishHymn.fetchFavorites(),
      responsive.fetchFavorites(),
      yorubaHymn.fetchFavorites(),
    ]);

    FlutterNativeSplash.remove();

    // Ads start only after consent (and iOS tracking permission), which needs
    // the app on screen to show its prompts.
    WidgetsBinding.instance.addPostFrameCallback((_) => AdHelper.initialize());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            debugPrint("Error during initialization: ${snapshot.error}");
            debugPrint("Stack trace: ${snapshot.stackTrace}");
            return Scaffold(
              body: Center(
                child: Text('Error initializing app. Please restart.'),
              ),
            );
          }
          return const MyHomePage();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;

  final _pageOptions = [
    HomeScreen(),
    Favourites(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _selectedPage,
        onTap: (index) => setState(() => _selectedPage = index),
        selectedItemColor: PlatformInfo.isIOS ? null : brandGreen,
        items: [
          AdaptiveNavigationDestination(
            icon: platformIcon(
              sfSymbol: 'house.fill',
              cupertino: CupertinoIcons.house_fill,
              material: Icons.home_outlined,
            ),
            selectedIcon: PlatformInfo.isIOS ? null : Icons.home,
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: platformIcon(
              sfSymbol: 'heart.fill',
              cupertino: CupertinoIcons.heart_fill,
              material: Icons.favorite_border,
            ),
            selectedIcon: PlatformInfo.isIOS ? null : Icons.favorite,
            label: 'Favourites',
          ),
          AdaptiveNavigationDestination(
            icon: platformIcon(
              sfSymbol: 'magnifyingglass',
              cupertino: CupertinoIcons.search,
              material: Icons.search,
            ),
            label: 'Search',
            isSearch: true,
          ),
          AdaptiveNavigationDestination(
            icon: platformIcon(
              sfSymbol: 'gearshape.fill',
              cupertino: CupertinoIcons.gear_solid,
              material: Icons.settings_outlined,
            ),
            selectedIcon: PlatformInfo.isIOS ? null : Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
