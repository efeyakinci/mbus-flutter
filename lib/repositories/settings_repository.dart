import 'dart:convert';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:mbus/preferences_keys.dart';

class SettingsRepository {
  final StreamingSharedPreferences prefs;
  SettingsRepository(this.prefs);

  bool get isColorBlind =>
      prefs.getBool(PrefKeys.colorBlindEnabled, defaultValue: false).getValue();
  Future<void> setColorBlind(bool value) async {
    await prefs
        .getBool(PrefKeys.colorBlindEnabled, defaultValue: false)
        .setValue(value);
  }

  bool get isDarkMode =>
      prefs.getBool(PrefKeys.darkModeEnabled, defaultValue: false).getValue();
  Future<void> setDarkMode(bool value) async {
    await prefs
        .getBool(PrefKeys.darkModeEnabled, defaultValue: false)
        .setValue(value);
  }

  bool get hasOnboarded =>
      prefs.getBool(PrefKeys.onboarded, defaultValue: false).getValue();
  Future<void> setOnboarded(bool value) async {
    await prefs
        .getBool(PrefKeys.onboarded, defaultValue: false)
        .setValue(value);
  }

  Set<String> get selectedRouteIds {
    final stored =
        prefs.getString(PrefKeys.selectedRoutes, defaultValue: '[]').getValue();
    if (stored.isEmpty) return <String>{};
    final dynamic parsed = jsonDecode(stored);
    if (parsed is List) {
      if (parsed.isEmpty) return <String>{};
      final first = parsed.first;
      if (first is String) {
        return parsed.cast<String>().toSet();
      }
      if (first is Map<String, dynamic>) {
        final ids = <String>[for (final m in parsed) m['routeId'] as String];
        prefs
            .getString(PrefKeys.selectedRoutes, defaultValue: '[]')
            .setValue(jsonEncode(ids));
        return ids.toSet();
      }
    }
    throw const FormatException('Invalid selectedRoutes format');
  }

  Future<void> setSelectedRouteIds(Set<String> ids) async {
    await prefs
        .getString(PrefKeys.selectedRoutes, defaultValue: '[]')
        .setValue(jsonEncode(ids.toList()));
  }

  // Reactive preferences so controllers can subscribe
  Preference<bool> get isColorBlindPref =>
      prefs.getBool(PrefKeys.colorBlindEnabled, defaultValue: false);
  Preference<bool> get isDarkModePref =>
      prefs.getBool(PrefKeys.darkModeEnabled, defaultValue: false);
  Preference<bool> get onboardedPref =>
      prefs.getBool(PrefKeys.onboarded, defaultValue: false);
  Preference<String> get selectedRouteIdsPref =>
      prefs.getString(PrefKeys.selectedRoutes, defaultValue: '[]');
}
