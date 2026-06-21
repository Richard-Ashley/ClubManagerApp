class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Session expired. Please log in again.'])
      : super(message, statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found.'])
      : super(message, statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException([String message = 'This action conflicts with existing data.'])
      : super(message, statusCode: 409);
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error. Check your connection.'])
      : super(message);
}
