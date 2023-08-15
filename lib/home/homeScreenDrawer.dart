import 'package:flutter/material.dart';

//3rd packages
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

//app imports
import 'package:didit/common/platformization.dart';

import 'package:didit/onboarding/onboarding.dart';
import 'package:didit/settings_page/settings_page.dart';

//Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        return AppLocalizations.of(context)!.quality_low;
      case ResolutionPreset.medium:
        return AppLocalizations.of(context)!.quality_medium;
      case ResolutionPreset.high:
        return AppLocalizations.of(context)!.quality_high;
      case ResolutionPreset.veryHigh:
        return AppLocalizations.of(context)!.quality_very_high;
      case ResolutionPreset.ultraHigh:
        return AppLocalizations.of(context)!.quality_ultra_high;
      case ResolutionPreset.max:
        return AppLocalizations.of(context)!.quality_max;
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
                        title: Text(AppLocalizations.of(context)!.settings),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SettingsPage()));
                        },
                      ),
                      ListTile(
                        leading: Icon(getFeedbackIcon()),
                        title:
                            Text(AppLocalizations.of(context)!.send_feedback),
                        onTap: _launchEmail,
                      ),
                      /*                      ListTile(
                        leading: Icon(getFavouriteIcon()),
                        title: Text(AppLocalizations.of(context)!.buy_coffee),
                        onTap: _launchBuyMeACoffeeUrl,
                      ),*/
                      ListTile(
                        leading: Icon(getListIcon()),
                        title: Text(
                            AppLocalizations.of(context)!.relaunch_tutorial),
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
    const String emailAddress = "didit@nacar.dev";
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
