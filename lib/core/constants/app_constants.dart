class AppConstants {
  AppConstants._();

  // Android emulator → http://10.0.2.2:5014 (maps to host machine's localhost)
  // Physical device  → http://YOUR_LOCAL_IP:5014
  // iOS simulator    → https://localhost:7190
  static const String baseUrl = 'http://10.0.2.2:5014';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const String appName = 'Club Manager';
}
