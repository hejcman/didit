import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings
import 'globals.dart';

// Design
import 'common/color_schemes.g.dart';

// Database
import 'storage/schema.dart';

// OnBoarding
import 'onboarding/onboarding.dart';

// Home page
import 'home/home.dart';

Future<void> main(List<String> args) async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Prepare the DB
  await Hive.initFlutter();
  generateAdapters();
  Hive.openBox<Memory>(Globals.dbName);

  // Prepare the default settings
  var prefs = await SharedPreferences.getInstance();
  setDefaults(prefs, overwrite: false);

  // Launch the app
  runApp(MyApp(onboarding: prefs.getBool(Settings.showOnboarding.key)!));
}

class MyApp extends StatefulWidget {
  final bool onboarding;

  const MyApp({super.key, this.onboarding = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        home: widget.onboarding ? const OnBoardingView() : const HomeScreen());
  }
}
