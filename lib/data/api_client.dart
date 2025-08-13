import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mbus/constants.dart';
import 'package:mbus/data/api_errors.dart';

// DTOs
class RouteInformationDto {
  final Map<String, dynamic> json;
  RouteInformationDto(this.json);
}

class AllRoutesDto {
  final Map<String, dynamic> routes; // routeId -> list of segments
  AllRoutesDto(this.routes);
}

class VehiclePositionsDto {
  final List<dynamic> buses;
  VehiclePositionsDto(this.buses);
}

class UpdateNotesDto {
  final String version;
  final String message;
  UpdateNotesDto({required this.version, required this.message});
}

class StartupMessageDto {
  final String id;
  final String title;
  final String message;
  final String buildVersion;
  StartupMessageDto({
    required this.id,
    required this.title,
    required this.message,
    required this.buildVersion,
  });
}

class SelectableRoutesDto {
  final List<dynamic> routes; // raw list from API to be mapped by caller
  SelectableRoutesDto(this.routes);
}

abstract class MBusApiClient {
  Future<RouteInformationDto> getRouteInformation({required bool colorblind});
  Future<AllRoutesDto> getAllRoutes();
  Future<VehiclePositionsDto> getVehiclePositions();
  Future<UpdateNotesDto> getUpdateNotes();
  Future<StartupMessageDto> getStartupMessages();
  Future<SelectableRoutesDto> getSelectableRoutes();
  Future<void> giveFeedback(String feedbackBody);
  Future<int> getRouteInfoVersion();
  Future<Map<String, dynamic>> getStopPredictions(String stopId);
  Future<Map<String, dynamic>> getBusPredictions(String busId);
}

class HttpMBusApiClient implements MBusApiClient {
  final http.Client _client;
  HttpMBusApiClient(this._client);

  Uri _uri(String pathWithNoLeadingSlash) =>
      Uri.parse('$BACKEND_URL/$pathWithNoLeadingSlash');

  Future<Map<String, dynamic>> _getJson(String path) async {
    http.Response res;
    try {
      res = await _client.get(_uri(path));
    } catch (e) {
      throw NetworkException('Network failure: $e');
    }
    if (res.statusCode == 429) {
      throw RateLimitException('Too many requests');
    }
    if (res.statusCode != 200) {
      throw ServerException('HTTP ${res.statusCode} for GET $path',
          statusCode: res.statusCode);
    }
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ParseException('Expected JSON object for $path');
      }
      return decoded;
    } catch (e) {
      throw ParseException('Failed to parse response for $path: $e');
    }
  }

  @override
  Future<RouteInformationDto> getRouteInformation({required bool colorblind}) async {
    final json = await _getJson('getRouteInformation?colorblind=${colorblind ? 'Y' : 'N'}');
    return RouteInformationDto(json);
  }

  @override
  Future<AllRoutesDto> getAllRoutes() async {
    final json = await _getJson('getAllRoutes');
    final routes = json['routes'];
    if (routes is! Map<String, dynamic>) {
      throw ParseException('Invalid routes payload');
    }
    return AllRoutesDto(routes);
  }

  @override
  Future<VehiclePositionsDto> getVehiclePositions() async {
    final json = await _getJson('getVehiclePositions');
    final buses = json['buses'];
    if (buses is! List) {
      throw ParseException('Invalid buses payload');
    }
    return VehiclePositionsDto(buses);
  }

  @override
  Future<UpdateNotesDto> getUpdateNotes() async {
    final json = await _getJson('getUpdateNotes');
    final version = (json['version'] ?? '').toString();
    final message = (json['message'] ?? '').toString();
    return UpdateNotesDto(version: version, message: message);
  }

  @override
  Future<StartupMessageDto> getStartupMessages() async {
    final json = await _getJson('get-startup-messages');
    return StartupMessageDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      buildVersion: (json['buildVersion'] ?? '').toString(),
    );
  }

  @override
  Future<SelectableRoutesDto> getSelectableRoutes() async {
    final json = await _getJson('getSelectableRoutes');
    final routes = (json['bustime-response']?['routes']);
    if (routes is! List) {
      throw ParseException('Invalid selectable routes payload');
    }
    return SelectableRoutesDto(routes);
  }

  @override
  Future<void> giveFeedback(String feedbackBody) async {
    try {
      final res = await _client.post(_uri('api/give-feedback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'feedbackBody': feedbackBody}));
      if (res.statusCode == 429) {
        throw RateLimitException('Too many requests');
      }
      if (res.statusCode != 200) {
        throw ServerException('HTTP ${res.statusCode} while posting feedback',
            statusCode: res.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network failure: $e');
    }
  }

  @override
  Future<int> getRouteInfoVersion() async {
    final json = await _getJson('getRouteInfoVersion');
    final v = json['version'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    throw ParseException('Invalid route info version');
  }

  @override
  Future<Map<String, dynamic>> getStopPredictions(String stopId) async {
    final json = await _getJson('getStopPredictions/$stopId');
    final body = json['bustime-response'];
    if (body is Map<String, dynamic>) return body;
    throw ParseException('Invalid stop predictions payload');
  }

  @override
  Future<Map<String, dynamic>> getBusPredictions(String busId) async {
    final json = await _getJson('getBusPredictions/$busId');
    final body = json['bustime-response'];
    if (body is Map<String, dynamic>) return body;
    throw ParseException('Invalid bus predictions payload');
  }
}


