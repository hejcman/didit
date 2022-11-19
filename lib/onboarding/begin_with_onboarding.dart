import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding.dart';

class BeginWithOnBoarding extends StatefulWidget {
  const BeginWithOnBoarding({
    Key? key,
    this.home,
  }) : super(key: key);

  final Widget? home;

  @override
  State<BeginWithOnBoarding> createState() => _BeginWithOnBoardingState();
}

class _BeginWithOnBoardingState extends State<BeginWithOnBoarding> {
  // Shared User preferences instance
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<bool> _displayOnBoarding;

  Future<void> changeFirstVisit() async {
    final SharedPreferences prefs = await _prefs;
    final bool displayOnBoarding = prefs.getBool('displayOnBoarding') ?? true;

    setState(() {
      _displayOnBoarding = prefs
          .setBool('displayOnBoarding', !displayOnBoarding)
          .then((bool success) {
        return displayOnBoarding;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // TODO: DEV line to remove data inorder to run on-boarding every time
    /*_prefs.then((SharedPreferences prefs) {
      prefs.remove('displayOnBoarding');
    });*/

    _displayOnBoarding = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('displayOnBoarding') ?? true;
    });
  }

  //

  @override
  Widget build(BuildContext context) {
    // return _displayOnBoarding ? OnBoardingView() : const MyHomePage(title: "Main Page");
    return FutureBuilder<bool>(
        future: _displayOnBoarding,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data == true
                    ? const OnBoardingView()
                    : widget.home!;
              }
          }
        });
  }
}
