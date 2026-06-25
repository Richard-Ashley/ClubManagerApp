import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/design_system.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/auth_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final firstName = (user?.fullName ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                eyebrow: 'Welcome',
                title: 'Hello,\n$firstName.',
                trailing: GestureDetector(
                  onTap: () => ref.read(authNotifierProvider.notifier).logout(),
                  child: const Icon(Icons.logout, size: 22, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 36),
              _HomeCard(
                eyebrow: 'Explore',
                title: 'Browse venues',
                description: 'See what is open and book a slot.',
                onTap: () => context.push(AppRoutes.venues),
              ),
              const SizedBox(height: 12),
              _HomeCard(
                eyebrow: 'Your day',
                title: 'My bookings',
                description: 'Manage upcoming and past reservations.',
                onTap: () => context.push(AppRoutes.bookings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(eyebrow),
                    const SizedBox(height: 8),
                    Text(title, style: AppTypography.title.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(description, style: AppTypography.bodyMuted),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 18, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
