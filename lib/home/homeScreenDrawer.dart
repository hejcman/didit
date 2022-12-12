import 'package:flutter/material.dart';

//3rd packages
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

//app imports
import 'package:didit/common/platformization.dart';

import 'package:didit/onboarding/onboarding.dart';
import 'package:didit/settings_page/settings_page.dart';

class HomeScreenDrawer extends StatefulWidget {
  const HomeScreenDrawer({super.key});

  @override
  State<HomeScreenDrawer> createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _prefs,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          return Drawer(
            child: SafeArea(
              child: ValueListenableBuilder(
                valueListenable: prefsUpdated,
                builder: (BuildContext context, bool value, Widget? child) {
                  return ListView(
                    padding: const EdgeInsets.all(10),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(getSettingsIcon()),
                        title: const Text('Settings'),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SettingsPage()));
                        },
                      ),
                      ListTile(
                        leading: Icon(getFeedbackIcon()),
                        title: const Text('Send feedback'),
                        onTap: _launchEmail,
                      ),
                      ListTile(
                        leading: Icon(getFavouriteIcon()),
                        title: const Text('Buy us a coffee'),
                        onTap: _launchBuyMeACoffeeUrl,
                      ),
                      ListTile(
                        leading: Icon(getListIcon()),
                        title: const Text('Relaunch tutorial'),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const OnBoardingView()));
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  Future<void> _launchEmail() async {
    const String emailAddress = "support@didit.com";
    const String subject = "DidIt - feedback";
    final url = Uri.parse('mailto:$emailAddress?subject=$subject');
    if (!await launchUrl(url)) {
      throw 'Could not launch email';
    }
  }

  Future<void> _launchBuyMeACoffeeUrl() async {
    Uri url = Uri.parse('https://www.buymeacoffee.com/arthurnacar');
    if (!await launchUrl(url)) {
      throw 'Could not launch https://www.buymeacoffee.com/arthurnacar';
    }
  }
}
