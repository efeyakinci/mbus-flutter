class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode});
}

class ParseException extends ApiException {
  ParseException(super.message);
}

class RateLimitException extends ApiException {
  RateLimitException(super.message, {int? retryAfterSeconds})
      : super(statusCode: 429);
}
