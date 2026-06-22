class AppUser {
  const AppUser({
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String fullName;
  final String email;
  final String role;

  bool get isAdmin => role == 'Admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AppUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        user: AppUser.fromJson(json),
      );
}
