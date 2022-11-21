
import 'package:shared_preferences/shared_preferences.dart';

///// GLOBAL VARIABLES /////

class Globals {
  /// The name of the DB in which the memories are stored.
  static const String dbName = "memories";
}

///// SETTINGS /////

enum Settings {

  cameraQuality(
      key: "camera_quality",
      defaultValue: 3,
      description: "The quality of the pictures saved by the camera."),

  showOnboarding(
      key: "show_onboarding",
      defaultValue: true,
      description: "Whether to show the onboarding screen on the next startup of the application."
  );

  final String key;
  final dynamic defaultValue;
  final String description;
  const Settings({ required this.key, required this.defaultValue, required this.description});

}

/// Save the current defaults into the database.
///
/// @param prefs The object holding the SharedPreferences.
/// @param overwrite If set to true, disregard any exisitng values in the database and overwrite
///                  them with the defaults.
void setDefaults(SharedPreferences prefs, {bool overwrite = false}) {
  for (final s in Settings.values) {
    final currentValue = prefs.get(s.key);
    if ((currentValue == null) || (currentValue != s.defaultValue && overwrite)) {
      switch (s.defaultValue.runtimeType) {
        case bool:
          prefs.setBool(s.key, s.defaultValue);
          break;
        case int:
          prefs.setInt(s.key, s.defaultValue);
          break;
        case double:
          prefs.setDouble(s.key, s.defaultValue);
          break;
        case String:
          prefs.setString(s.key, s.defaultValue);
          break;
        case List<String>:
          prefs.setString(s.key, s.defaultValue);
          break;
        default:
          throw Exception("Unsupported setting data type!");
      }
    }
  }
}
