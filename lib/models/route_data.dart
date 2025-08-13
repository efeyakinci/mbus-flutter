import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_data.freezed.dart';
part 'route_data.g.dart';

@freezed
abstract class RouteData with _$RouteData {
  const factory RouteData({
    required String routeId,
    required String routeName,
  }) = _RouteData;

  factory RouteData.fromJson(Map<String, dynamic> json) => _$RouteDataFromJson(json);
}


