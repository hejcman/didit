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
  final ValueNotifier<bool> prefsUpdated = ValueNotifier(false);
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _prefs.then((value) => prefs = value);
  }

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

  Future showResetDialog() {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                  "Do you want to reset all the settings to their defaults?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    setDefaults(prefs, overwrite: true);
                    // Setting the defaults shouldn't launch the onboarding
                    prefs.setBool(Settings.showOnboarding.key, false);
                    // Send a signal to refresh the settings page
                    debugPrint("Resetting the settings.");
                    prefsUpdated.value = !prefsUpdated.value;
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _prefs,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(getBackArrowIcon()),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              title: const Text("Settings"),
            ),
            body: ValueListenableBuilder(
              valueListenable: prefsUpdated,
              builder: (BuildContext context, bool value, Widget? child) {
                return ListView(
                  padding: const EdgeInsets.all(10),
                  children: <Widget>[
                    Card(
                        child: ListTile(
                      leading: Icon(Icons.image),
                      title: Text("Picture quality"),
                      trailing: DropdownButton(
                        value: resolutions[
                            prefs.getInt(Settings.cameraQuality.key)!],
                        items: resolutions
                            .map<DropdownMenuItem>((ResolutionPreset res) {
                          return DropdownMenuItem(
                              value: res, child: Text(resolutionToString(res)));
                        }).toList(),
                        onChanged: (value) {
                          prefs.setInt(Settings.cameraQuality.key,
                              ResolutionPreset.values.toList().indexOf(value));
                          setState(() {
                            value = value;
                          });
                        },
                      ),
                    )),
                    Card(
                        child: ListTile(
                      leading: Icon(Icons.vibration),
                      title: Text("Enable shutter vibration"),
                      trailing: Switch(
                          value: prefs.getBool(Settings.enableVibration.key)!,
                          onChanged: (value) {
                            prefs.setBool(Settings.enableVibration.key, value);
                            setState(() {
                              value = value;
                            });
                          }),
                    )),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.repeat),
                        title: Text(
                          "Reset to default",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          showResetDialog();
                        },
                      ),
                    ),
                  ],
                );
              },
            ));
      },
    );
  }
}
