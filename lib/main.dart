import 'dart:async';

import 'package:didit/home/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'globals.dart';

// Design
import 'common/color_schemes.g.dart';

// Database
import 'storage/schema.dart';

// OnBoarding
import 'onboarding/begin_with_onboarding.dart';

Future<void> main(List<String> args) async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Prepare the DB
  await Hive.initFlutter();
  generateAdapters();
  Hive.openBox<Memory>(Globals.dbName);

  // Launch the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const BeginWithOnBoarding(home: HomeScreen()),
    );
  }
}
