class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.'])
      : super(statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException(
      [super.message = 'This action conflicts with existing data.'])
      : super(statusCode: 409);
}

class NetworkException extends AppException {
  const NetworkException(
      [super.message = 'Network error. Check your connection.']);
}
