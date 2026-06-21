class AppConstants {
  AppConstants._();

  // Change this to your machine's local IP when testing on a physical device
  // For emulator use: http://10.0.2.2:5190
  // For physical device use: http://YOUR_LOCAL_IP:5190
  static const String baseUrl = 'https://localhost:7190';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const String appName = 'Club Manager';
}
