import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) {
    return _apiClient.post<AuthResult>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      fromJson: (data) => AuthResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _apiClient.post<AuthResult>(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
      fromJson: (data) => AuthResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
