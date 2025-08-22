import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/models/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_notifier.g.dart';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  static const _prefsKey = 'app_settings.v1';

  SharedPreferences? _prefs;
  Future<void> _writeQueue = Future<void>.value();

  @override
  Settings build() {
    Future.microtask(_hydrateFromDisk);

    ref.onDispose(() async {
      await _flushWrites();
    });

    return Settings.initial();
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _hydrateFromDisk() async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_prefsKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid settings format');
    }
    state = Settings.fromJson(decoded);
  }

  Future<void> _persist(Settings next) async {
    await _ensurePrefs();
    final payload = jsonEncode(next.toJson());
    final ok = await _prefs!.setString(_prefsKey, payload);
    if (!ok) {
      throw StateError('Failed to persist settings');
    }
  }

  Future<void> _flushWrites() async {
    await _writeQueue;
  }

  Future<void> update(Settings Function(Settings) mutate) async {
    final next = mutate(state);
    if (next == state) return;
    _writeQueue = _writeQueue.then((_) async {
      await _persist(next);
      state = next;
    });
    await _writeQueue;
  }

  Future<void> toggleDarkMode() async =>
      update((s) => s.copyWith(isDarkMode: !s.isDarkMode));
  Future<void> toggleColorBlind() async =>
      update((s) => s.copyWith(isColorBlind: !s.isColorBlind));
  Future<void> setHasOnboarded(bool v) async =>
      update((s) => s.copyWith(hasOnboarded: v));

  Future<void> addSelectedRouteId(String id) async => update((s) => s.copyWith(
        selectedRouteIds: {
          ...s.selectedRouteIds,
          id,
        },
      ));
  Future<void> removeSelectedRouteId(String id) async =>
      update((s) => s.copyWith(
            selectedRouteIds: s.selectedRouteIds.where((e) => e != id).toSet(),
          ));
  Future<void> setSelectedRouteIds(Set<String> ids) async =>
      update((s) => s.copyWith(selectedRouteIds: ids));
}
