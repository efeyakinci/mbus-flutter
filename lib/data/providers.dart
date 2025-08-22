import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mbus/data/api_client.dart';
import 'package:mbus/map/infrastructure/route_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final apiClientProvider = Provider<MBusApiClient>((ref) {
  final client = ref.watch(httpClientProvider);
  return HttpMBusApiClient(client);
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final repo = RouteRepository(api: api);
  ref.onDispose(repo.dispose);
  repo.start();
  return repo;
});

final routeSnapshotStreamProvider = StreamProvider((ref) {
  return ref.watch(routeRepositoryProvider).stream;
});

// assets repository removed; API is consumed directly where needed

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});
final streamingSharedPreferencesProvider =
    FutureProvider<StreamingSharedPreferences>((ref) async {
  return StreamingSharedPreferences.instance;
});

class FavoriteStopsNotifier extends AsyncNotifier<Set<String>> {
  static const String _prefsKey = 'favorites';
  Map<String, String> _favoritesById = const <String, String>{};

  // On startup -> hydrate
  @override
  Future<Set<String>> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final list = prefs.getStringList(_prefsKey) ?? const <String>[];
    final mapped = <String, String>{};
    for (final entry in list) {
      final decoded = jsonDecode(entry);
      if (decoded is! Map || decoded['stopId'] is! String) {
        throw const FormatException('Invalid favorite entry');
      }
      mapped[decoded['stopId'] as String] =
          (decoded['stopName'] ?? '') as String;
    }
    _favoritesById = mapped;
    return _favoritesById.keys.toSet();
  }

  // On add -> add & persist
  Future<void> addFavorite(
      {required String stopId, required String stopName}) async {
    final currentIds = state.value ?? _favoritesById.keys.toSet();
    if (currentIds.contains(stopId)) return;
    if (currentIds.length >= 5) return;

    final prefs = await ref.read(sharedPreferencesProvider.future);
    _favoritesById = {..._favoritesById, stopId: stopName};
    await prefs.setStringList(_prefsKey, _encode());
    state = AsyncData(_favoritesById.keys.toSet());
  }

  // On remove -> remove & persist
  Future<void> removeFavorite(String stopId) async {
    final currentIds = state.value ?? _favoritesById.keys.toSet();
    if (!currentIds.contains(stopId)) return;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final next = {..._favoritesById}..remove(stopId);
    _favoritesById = next;
    await prefs.setStringList(_prefsKey, _encode());
    state = AsyncData(_favoritesById.keys.toSet());
  }

  List<String> _encode() => _favoritesById.entries
      .map((e) => jsonEncode({'stopId': e.key, 'stopName': e.value}))
      .toList(growable: false);
}

final favoriteStopsProvider =
    AsyncNotifierProvider<FavoriteStopsNotifier, Set<String>>(
        FavoriteStopsNotifier.new);
