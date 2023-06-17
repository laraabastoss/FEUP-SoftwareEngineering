import 'package:brain_box/firebase_options.dart';
import 'package:brain_box/screens/forgot_password_screen.dart';
import 'package:brain_box/screens/login_screen.dart';
import 'package:brain_box/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import '../lib/main.dart';

Future<void> main() async {
  // This line enables the extension
  enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  runApp(Material(
      child:Localizations(
        locale: const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,],
        child:
        CupertinoApp(
          theme: const CupertinoThemeData(
              primaryColor: Colors.cyan,
              primaryContrastingColor: Colors.blue,
              barBackgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.white),
          routes: {
            '/': (_) => LoginScreen(),
            'register': (_) => RegistrationScreen(),
            'forgot-password': (_) => const ForgotPasswordScreen(),
            'main': (_) => MyApp(),
          },
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
        ),
      )));
}
