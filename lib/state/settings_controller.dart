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

  SettingsController(this._repository) : super(SettingsState.initial()) {
    state = SettingsState(
      isColorBlind: _repository.isColorBlind,
      hasOnboarded: _repository.hasOnboarded,
      selectedRouteIds: _repository.selectedRouteIds.toList(),
    );
  }

  void toggleColorBlind() {
    final newValue = !state.isColorBlind;
    state = state.copyWith(isColorBlind: newValue);
    _repository.setColorBlind(newValue);
  }

  void setOnboarded(bool value) {
    state = state.copyWith(hasOnboarded: value);
    _repository.setOnboarded(value);
  }

  void setSelectedRoutes(Set<String> ids) {
    state = state.copyWith(selectedRouteIds: ids.toList());
    _repository.setSelectedRouteIds(ids);
  }

} 