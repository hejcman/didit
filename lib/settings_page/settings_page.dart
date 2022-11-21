import 'dart:async';

import 'package:camera/camera.dart';
import 'package:didit/common/platformization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Onboarding
import '../onboarding/onboarding.dart';

// Globals
import '../globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<ResolutionPreset> resolutions = ResolutionPreset.values.toList();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _prefs.then((value) => prefs = value);
  }

  //
  // Future<void> getPreferences() async {
  //   prefs = await SharedPreferences.getInstance();
  // }

  String resolutionToString(ResolutionPreset resolution) {
    switch (resolution) {
      case ResolutionPreset.low:
        return "Low";
      case ResolutionPreset.medium:
        return "Medium";
      case ResolutionPreset.high:
        return "High";
      case ResolutionPreset.veryHigh:
        return "Very High";
      case ResolutionPreset.ultraHigh:
        return "Ultra High";
      case ResolutionPreset.max:
        return "Max";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(getBackArrowIcon()),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              title: const Text("Settings")
            ),
            body: FutureBuilder(
              future: _prefs,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                return ListView(
                  padding: const EdgeInsets.all(10),
                  children: <Widget>[
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              children: <Widget>[
                                const Expanded(child: Text("Picture quality")),
                                DropdownButton(
                                  value: resolutions[prefs.getInt(Settings.cameraQuality.key)!],
                                  items: resolutions.map<DropdownMenuItem>((ResolutionPreset res) {
                                    return DropdownMenuItem(value: res, child: Text(resolutionToString(res)));
                                  }).toList(),
                                  onChanged: (value) {
                                    prefs.setInt(
                                        Settings.cameraQuality.key, ResolutionPreset.values.toList().indexOf(value));
                                    setState(() {
                                      value = value;
                                    });
                                  },
                                )
                              ],
                            ))),
                    Card(
                        child: TextButton(
                            onPressed: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => const OnBoardingView()));
                            },
                            child: const Text("Re-launch the tutorial")))
                  ],
                );
              },
            )));
  }
}
