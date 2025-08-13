import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mbus/data/api_client.dart';
import 'package:mbus/repositories/assets_repository.dart';
import 'package:mbus/map/infrastructure/route_repository.dart';
import 'package:mbus/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final assetsRepositoryProvider = Provider<AssetsRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return AssetsRepository(api);
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (p) => p,
        orElse: () => null,
      );
  if (prefs == null) {
    throw StateError('SharedPreferences not ready');
  }
  return SettingsRepository(prefs);
});


