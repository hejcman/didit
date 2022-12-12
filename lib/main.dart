import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Settings
import 'globals.dart' as globals;

// Design
import 'common/color_schemes.g.dart';

// Database
import 'storage/schema.dart';

// OnBoarding
import 'onboarding/onboarding.dart';

// Home page
import 'home/homeScreen.dart';

Future<void> main(List<String> args) async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Make sure the device is always in portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Prepare the DB
  await Hive.initFlutter();
  generateAdapters();
  const secureStorage = FlutterSecureStorage();
  var keyExists = await secureStorage.read(key: 'hiveKey');
  if (keyExists == null) {
    final newKey = Hive.generateSecureKey();
    await secureStorage.write(key: 'hiveKey', value: base64UrlEncode(newKey));
  }
  final key = await secureStorage.read(key: 'hiveKey');
  final encryptionKey = base64Url.decode(key!);
  globals.box = await Hive.openBox<Memory>(globals.dbName, encryptionCipher: HiveAesCipher(encryptionKey));

  // Prepare the default settings
  globals.prefs = await SharedPreferences.getInstance();
  globals.setDefaults(globals.prefs, overwrite: false);

  globals.cameras = await availableCameras();

  // Launch the app
  FlutterNativeSplash.remove();
  runApp(MyApp(onboarding: globals.prefs.getBool(globals.Settings.showOnboarding.key)!));
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
      initialRoute: widget.onboarding ? '/onboarding' : '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnBoardingView(),
      },
    );
  }
}
