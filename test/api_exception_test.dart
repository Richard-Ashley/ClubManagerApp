import 'package:club_manager_app/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('keeps its message and optional status code', () {
      const error = AppException('boom', statusCode: 500);

      expect(error.message, 'boom');
      expect(error.statusCode, 500);
      expect(error.toString(), 'boom');
    });

    test('status code is optional', () {
      expect(const AppException('boom').statusCode, isNull);
    });
  });

  group('typed exceptions', () {
    test('map to the expected HTTP status codes', () {
      expect(const UnauthorizedException().statusCode, 401);
      expect(const NotFoundException().statusCode, 404);
      expect(const ConflictException().statusCode, 409);
    });

    test('network errors carry no status code', () {
      expect(const NetworkException().statusCode, isNull);
    });

    test('have a default user-facing message', () {
      expect(const UnauthorizedException().message,
          'Session expired. Please log in again.');
      expect(const NotFoundException().message, 'Resource not found.');
      expect(const ConflictException().message,
          'This action conflicts with existing data.');
      expect(const NetworkException().message,
          'Network error. Check your connection.');
    });

    test('accept a custom message', () {
      expect(const NotFoundException('No such venue').message, 'No such venue');
    });

    test('are all AppExceptions', () {
      expect(const UnauthorizedException(), isA<AppException>());
      expect(const NotFoundException(), isA<AppException>());
      expect(const ConflictException(), isA<AppException>());
      expect(const NetworkException(), isA<AppException>());
    });
  });
}
