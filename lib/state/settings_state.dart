import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

// Stub annotation to satisfy generated code
class HiveField {
  final int index;
  const HiveField(this.index);
}

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isColorBlind,
    @Default(false) bool hasOnboarded,
    @Default(<String>[]) List<String> selectedRouteIds,
  }) = _SettingsState;

  factory SettingsState.initial() => const SettingsState();
}