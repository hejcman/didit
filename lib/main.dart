import 'dart:async';

import 'package:didit/home/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'globals.dart';

// Database
import 'storage/schema.dart';

// Widgets
import 'gallery.dart';

Future<void> main(List<String> args) async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Prepare the DB
  await Hive.initFlutter();
  generateAdapters();
  Hive.openBox<Memory>(Globals.dbName);

  // Launch the app
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColorLight: Colors.deepPurpleAccent[100],
      primaryColorDark: Colors.purple[900],

      colorScheme: ColorScheme(
        //defined
        brightness: Brightness.light,
        primary: Colors.deepPurple.shade400,
        onPrimary: Colors.white, //text on primary
        secondary: Colors.deepOrange.shade100,
        onSecondary: Colors.black87, // text on secondary

        //dont know, where they are
        error: Colors.pink,
        onError: Colors.pink,
        background: Colors.white,
        onBackground: Colors.pink,
        surface: Colors.pink,
        onSurface: Colors.pink,
      )
    ),
    home: HomeScreen(),
  ));

}

