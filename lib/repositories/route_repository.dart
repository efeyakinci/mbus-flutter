import 'dart:async';

// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/data/api_client.dart';
import 'package:mbus/data/api_errors.dart';

class RouteSnapshot {
  final Map<String, dynamic> allRoutes; // routeId -> segments
  final List<dynamic> buses; // raw bus entries
  RouteSnapshot({required this.allRoutes, required this.buses});
}

class RouteRepository {
  final MBusApiClient api;
  final _controller = StreamController<RouteSnapshot>.broadcast();
  Stream<RouteSnapshot> get stream => _controller.stream;

  Map<String, dynamic>? _routesCache;
  List<dynamic> _busesCache = const [];

  Timer? _busTimer;
  Timer? _routeTimer;
  int _failureCount = 0;

  RouteRepository({required this.api});

  void start() {
    _pollRoutes();
    _pollBuses();
    _routeTimer?.cancel();
    _routeTimer = Timer.periodic(const Duration(minutes: 1), (_) => _pollRoutes());
    _busTimer?.cancel();
    _busTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollBuses());
  }

  void dispose() {
    _busTimer?.cancel();
    _routeTimer?.cancel();
    _controller.close();
  }

  Future<void> _pollRoutes() async {
    try {
      final res = await api.getAllRoutes();
      _routesCache = res.routes;
      _emit();
      _failureCount = 0;
    } on ApiException {
      _backoff();
      rethrow;
    }
  }

  Future<void> _pollBuses() async {
    try {
      final res = await api.getVehiclePositions();
      _busesCache = res.buses;
      _emit();
      _failureCount = 0;
    } on ApiException {
      _backoff();
      rethrow;
    }
  }

  void _emit() {
    if (_routesCache == null) return;
    _controller.add(RouteSnapshot(allRoutes: _routesCache!, buses: _busesCache));
  }

  void _backoff() {
    _failureCount = (_failureCount + 1).clamp(1, 6);
    // jittered backoff: up to 2^n seconds, capped
    final base = Duration(seconds: 1 << (_failureCount - 1));
    final jitterMs = (base.inMilliseconds * 0.3).toInt();
    final delay = base + Duration(milliseconds: _randomJitter(jitterMs));
    _busTimer?.cancel();
    _busTimer = Timer(delay, _pollBuses);
  }

  int _randomJitter(int maxMs) {
    return DateTime.now().microsecondsSinceEpoch % (maxMs + 1);
  }
}

