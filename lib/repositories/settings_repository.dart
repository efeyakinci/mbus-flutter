import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbus/preferences_keys.dart';

class SettingsRepository {
  final SharedPreferences prefs;
  SettingsRepository(this.prefs);

  bool get isColorBlind => prefs.getBool(PrefKeys.colorBlindEnabled) ?? false;
  Future<void> setColorBlind(bool value) async {
    await prefs.setBool(PrefKeys.colorBlindEnabled, value);
  }

  bool get hasOnboarded => prefs.getBool(PrefKeys.onboarded) ?? false;
  Future<void> setOnboarded(bool value) async {
    await prefs.setBool(PrefKeys.onboarded, value);
  }

  Set<String> get selectedRouteIds {
    final stored = prefs.getString(PrefKeys.selectedRoutes);
    if (stored == null || stored.isEmpty) return <String>{};
    final dynamic parsed = jsonDecode(stored);
    if (parsed is List) {
      if (parsed.isEmpty) return <String>{};
      final first = parsed.first;
      if (first is String) {
        return parsed.cast<String>().toSet();
      }
      if (first is Map<String, dynamic>) {
        final ids = <String>[for (final m in parsed) m['routeId'] as String];
        prefs.setString(PrefKeys.selectedRoutes, jsonEncode(ids));
        return ids.toSet();
      }
    }
    throw const FormatException('Invalid selectedRoutes format');
  }

  Future<void> setSelectedRouteIds(Set<String> ids) async {
    await prefs.setString(PrefKeys.selectedRoutes, jsonEncode(ids.toList()));
  }
}


