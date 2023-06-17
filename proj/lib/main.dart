import 'package:brain_box/firebase_options.dart';
import 'package:brain_box/providers/location_provider.dart';
import 'package:brain_box/screens/forgot_password_screen.dart';
import 'package:brain_box/screens/login_screen.dart';
import 'package:brain_box/screens/map_screen.dart';
import 'package:brain_box/screens/profile_screen.dart';
import 'package:brain_box/screens/registration_screen.dart';
import 'package:brain_box/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  Location location = Location();

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }
  runApp(Material(
    child:Localizations(
      locale: const Locale('en', 'US'),
      delegates: const <LocalizationsDelegate<dynamic>>[
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,],
      child:
    CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
          primaryColor: Colors.cyan,
          primaryContrastingColor: Colors.blue,
          barBackgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white),
      routes: {
        '/': (_) => const LoginScreen(),
        'register': (_) => RegistrationScreen(),
        'forgot-password': (_) => const ForgotPasswordScreen(),
        'main': (_) => MyApp(),
      },
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    ),
  )));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _buildBody = <Widget>[
    Builder(
      builder: (context) => ChangeNotifierProvider<LocationModel>(
        create: (_) => LocationModel(),
        key: const Key('map_icon'),
        child: MapMenu(),
      ),
    ),
    const SearchMenu(),
    /*Builder(
      builder: (context) => ChangeNotifierProvider<LocationModel>(
        create: (_) => LocationModel(),
        child: MySearchBar(),
        key: const Key('search_icon'),
      ),
    ),*/
    ProfileMenu(),
  ];

  @override
  Widget build(BuildContext context) {
    key:
    const Key('main_page');
    return CupertinoTabScaffold(
      /*body: Navigator(
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext _) => Builder(
                    builder: (context) => ChangeNotifierProvider<LocationModel>(
                      create: (_) => LocationModel(),
                      child: MapMenu(),
                    ),
                  );
              break;
            case 'place':
              Place place = settings.arguments as Place;
              builder = (BuildContext _) => LocationScreen(
                    place: place,
                  );
              break;
            case 'profile':
              builder = (BuildContext _) => ProfileMenu();
              break;
            default:
              builder = (BuildContext _) => Builder(
                    builder: (context) => ChangeNotifierProvider<LocationModel>(
                      create: (_) => LocationModel(),
                      child: MapMenu(),
                    ),
                  );
              break;
          }
          return MaterialPageRoute(builder: builder);
        },
      ),*/
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(key: Key('map_icon'), Icons.map),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
          icon: Icon(key: Key('search_icon'), Icons.search),
              label: 'Search'),
          if (!(FirebaseAuth.instance.currentUser?.isAnonymous ?? false)) const BottomNavigationBarItem(
                  icon: Icon(key: Key('profile_icon'), Icons.person),
                  label: 'Profile',
                ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _buildBody[index];
          },
        );
      },
    );
  }
}
