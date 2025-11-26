import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A simple global ValueNotifier to manage theme mode without external packages.
final ValueNotifier<ThemeMode> themeController = ValueNotifier(ThemeMode.light);

const String _kThemeModeKey = 'app_theme_mode';

String _modeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.light:
      return 'light';
    case ThemeMode.system:
    default:
      return 'system';
  }
}

ThemeMode _stringToMode(String? s) {
  switch (s) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    case 'system':
    default:
      return ThemeMode.light; // default to light if not set
  }
}

Future<void> initThemeMode() async {
  try {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kThemeModeKey);
    themeController.value = _stringToMode(s);
  } catch (_) {
    // ignore errors, keep default
  }
}

Future<void> setThemeModePersisted(ThemeMode mode) async {
  themeController.value = mode;
  try {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kThemeModeKey, _modeToString(mode));
  } catch (_) {
    // ignore persist errors
  }
}
