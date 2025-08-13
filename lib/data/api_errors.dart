class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);
}

class ParseException extends ApiException {
  ParseException(String message) : super(message);
}

class RateLimitException extends ApiException {
  RateLimitException(String message, {int? retryAfterSeconds})
      : super(message, statusCode: 429);
}


