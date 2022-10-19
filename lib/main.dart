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
      theme: ThemeData.light(),
      home: HomeScreen(),
    )
  );
}
