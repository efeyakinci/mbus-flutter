import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';
import 'dart:convert';
import 'package:mbus/preferences_keys.dart';

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<SettingsState> {
  late final SharedPreferences _prefs;

  SettingsController() : super(SettingsState.initial()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isColorBlind: _prefs.getBool(PrefKeys.colorBlindEnabled) ?? false,
      hasOnboarded: _prefs.getBool(PrefKeys.onboarded) ?? false,
      selectedRouteIds: _loadSelectedRouteIds(),
    );
  }

  void toggleColorBlind() {
    final newValue = !state.isColorBlind;
    state = state.copyWith(isColorBlind: newValue);
    _save();
  }

  void setOnboarded(bool value) {
    state = state.copyWith(hasOnboarded: value);
    _save();
  }

  void setSelectedRoutes(Set<String> ids) {
    state = state.copyWith(selectedRouteIds: ids.toList());
    _save();
  }

  Future<void> _save() async {
    await _prefs.setBool(PrefKeys.colorBlindEnabled, state.isColorBlind);
    await _prefs.setBool(PrefKeys.onboarded, state.hasOnboarded);
    await _prefs.setString(PrefKeys.selectedRoutes, _encodeRouteIds(state.selectedRouteIds));
  }

  List<String> _loadSelectedRouteIds() {
    final stored = _prefs.getString(PrefKeys.selectedRoutes);
    if (stored == null || stored.isEmpty) return <String>[];
    final List<dynamic> parsed = jsonDecode(stored);
    return parsed.cast<String>();
  }

  String _encodeRouteIds(List<String> ids) => jsonEncode(ids);
} 