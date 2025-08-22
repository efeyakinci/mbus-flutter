import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    required bool isColorBlind,
    required bool isDarkMode,
    required bool hasOnboarded,
    required Set<String> selectedRouteIds,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  factory Settings.initial() => const Settings(
        isColorBlind: false,
        isDarkMode: false,
        hasOnboarded: true,
        selectedRouteIds: {},
      );
}
