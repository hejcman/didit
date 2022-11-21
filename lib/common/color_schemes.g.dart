import 'package:flutter/material.dart';

extension DarkMode on BuildContext {

  /// Check whether we currently use the dark mode or the light mode.
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6F4DA0),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFEDDCFF),
  onPrimaryContainer: Color(0xFF290055),
  secondary: Color(0xFF9C4049),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDADA),
  onSecondaryContainer: Color(0xFF40000C),
  tertiary: Color(0xFF84468D),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD6FF),
  onTertiaryContainer: Color(0xFF350040),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF320047),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF320047),
  surfaceVariant: Color(0xFFE8E0EB),
  onSurfaceVariant: Color(0xFF4A454E),
  outline: Color(0xFF7B757F),
  onInverseSurface: Color(0xFFFEEBFF),
  inverseSurface: Color(0xFF4B1662),
  inversePrimary: Color(0xFFD7BAFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF6F4DA0),
  //outlineVariant: Color(0xFFCCC4CF),
  //scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD7BAFF),
  onPrimary: Color(0xFF3F1B6E),
  primaryContainer: Color(0xFF573486),
  onPrimaryContainer: Color(0xFFEDDCFF),
  secondary: Color(0xFFFFB3B6),
  onSecondary: Color(0xFF5F121E),
  secondaryContainer: Color(0xFF7D2933),
  onSecondaryContainer: Color(0xFFFFDADA),
  tertiary: Color(0xFFF6ADFD),
  onTertiary: Color(0xFF50145B),
  tertiaryContainer: Color(0xFF6A2E74),
  onTertiaryContainer: Color(0xFFFFD6FF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF320047),
  onBackground: Color(0xFFF8D8FF),
  surface: Color(0xFF320047),
  onSurface: Color(0xFFF8D8FF),
  surfaceVariant: Color(0xFF4A454E),
  onSurfaceVariant: Color(0xFFCCC4CF),
  outline: Color(0xFF958E99),
  onInverseSurface: Color(0xFF320047),
  inverseSurface: Color(0xFFF8D8FF),
  inversePrimary: Color(0xFF6F4DA0),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFD7BAFF),
  //outlineVariant: Color(0xFF4A454E),
  //scrim: Color(0xFF000000),
);
