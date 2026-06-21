import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_routes.dart';

// Placeholder — will be replaced when screens are built
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(title)),
      );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen('Login'),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const _PlaceholderScreen('Register'),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen('Home'),
      ),
      GoRoute(
        path: AppRoutes.venues,
        name: 'venues',
        builder: (context, state) => const _PlaceholderScreen('Venues'),
      ),
      GoRoute(
        path: AppRoutes.bookings,
        name: 'bookings',
        builder: (context, state) => const _PlaceholderScreen('Bookings'),
      ),
      GoRoute(
        path: AppRoutes.newBooking,
        name: 'newBooking',
        builder: (context, state) => const _PlaceholderScreen('New Booking'),
      ),
    ],
  );
});
