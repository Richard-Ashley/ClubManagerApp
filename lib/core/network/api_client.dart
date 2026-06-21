import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient(TokenStorage tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  late final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    // Already mapped by interceptor
    if (e.error is AppException) return e.error as AppException;

    final statusCode = e.response?.statusCode;
    final message = _extractMessage(e.response?.data) ?? e.message ?? 'Unknown error';

    return switch (statusCode) {
      400 => AppException(message, statusCode: 400),
      401 => UnauthorizedException(message),
      403 => AppException('Access denied.', statusCode: 403),
      404 => NotFoundException(message),
      409 => ConflictException(message),
      _   => e.type == DioExceptionType.connectionTimeout ||
             e.type == DioExceptionType.receiveTimeout
          ? const NetworkException()
          : AppException(message),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['error'] as String? ?? data['message'] as String?;
    }
    return null;
  }
}
