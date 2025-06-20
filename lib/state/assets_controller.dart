import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/services/asset_loader.dart';
import 'assets_state.dart';

final assetsProvider =
    AsyncNotifierProvider<AssetsController, AssetsState>(AssetsController.new);

class AssetsController extends AsyncNotifier<AssetsState> {
  final _loader = AssetLoader();

  @override
  Future<AssetsState> build() async {
    // Assets will be loaded lazily by callers when context is available.
    return AssetsState.initial();
  }
}

// A global navigator key provider to access context while away from widgets.
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  throw UnimplementedError('Navigator key not set');
}); 