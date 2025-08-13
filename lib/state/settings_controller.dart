import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_state.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/repositories/settings_repository.dart';

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return SettingsController(repo);
});

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;
  StreamSubscription<bool>? _colorBlindSub;
  StreamSubscription<bool>? _darkModeSub;
  StreamSubscription<bool>? _onboardedSub;
  StreamSubscription<String>? _selectedRoutesSub;

  SettingsController(this._repository) : super(SettingsState.initial()) {
    state = SettingsState(
      isColorBlind: _repository.isColorBlind,
      isDarkMode: _repository.isDarkMode,
      hasOnboarded: _repository.hasOnboarded,
      selectedRouteIds: _repository.selectedRouteIds.toList(),
    );

    _colorBlindSub = _repository.isColorBlindPref.listen(
      (v) => state = state.copyWith(isColorBlind: v),
    );
    _darkModeSub = _repository.isDarkModePref.listen(
      (v) => state = state.copyWith(isDarkMode: v),
    );
    _onboardedSub = _repository.onboardedPref.listen(
      (v) => state = state.copyWith(hasOnboarded: v),
    );
    _selectedRoutesSub = _repository.selectedRouteIdsPref.listen((raw) {
      final List<dynamic> parsed = raw.isEmpty ? [] : (jsonDecode(raw) as List);
      final ids = parsed.cast<String>();
      state = state.copyWith(selectedRouteIds: ids);
    });
  }

  @override
  void dispose() {
    _colorBlindSub?.cancel();
    _darkModeSub?.cancel();
    _onboardedSub?.cancel();
    _selectedRoutesSub?.cancel();
    super.dispose();
  }

  void toggleColorBlind() {
    _repository.setColorBlind(!state.isColorBlind);
  }

  void setOnboarded(bool value) {
    _repository.setOnboarded(value);
  }

  void setSelectedRoutes(Set<String> ids) {
    _repository.setSelectedRouteIds(ids);
  }

  void toggleDarkMode() {
    _repository.setDarkMode(!state.isDarkMode);
  }
}
