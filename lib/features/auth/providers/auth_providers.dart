import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(repository, tokenStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._tokenStorage) : super(const AuthInitial()) {
    _restoreSession();
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<void> _restoreSession() async {
    final token = await _tokenStorage.getToken();
    if (token == null) {
      state = const AuthUnauthenticated();
      return;
    }

    final info = await _tokenStorage.getUserInfo();
    if (info['email'] == null) {
      state = const AuthUnauthenticated();
      return;
    }

    state = AuthAuthenticated(AppUser(
      fullName: info['name'] ?? '',
      email: info['email']!,
      role: info['role'] ?? 'Member',
    ));
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final result = await _repository.login(email: email, password: password);
      await _persistSession(result);
      state = AuthAuthenticated(result.user);
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _persistSession(result);
      state = AuthAuthenticated(result.user);
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearAll();
    state = const AuthUnauthenticated();
  }

  Future<void> _persistSession(AuthResult result) async {
    await _tokenStorage.saveToken(result.token);
    await _tokenStorage.saveUserInfo(
      email: result.user.email,
      name: result.user.fullName,
      role: result.user.role,
    );
  }
}
