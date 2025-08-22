import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  throw UnimplementedError('Navigator key not set');
});

// Current bottom tab index for top-level navigation
final currentTabProvider = StateProvider<int>((ref) => 0);
