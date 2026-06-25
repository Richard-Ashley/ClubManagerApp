import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/design_system.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/auth_state.dart';
import '../../bookings/providers/booking_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final bookingsAsync = ref.watch(bookingsBucketedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: [
            const Eyebrow('Profile'),
            const SizedBox(height: 6),
            const DisplayHeadline('Account &\nactivity.'),
            const SizedBox(height: 24),

            // ID card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InitialsAvatar(user?.fullName ?? '', size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Guest',
                              style: AppTypography.title.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            StatusPill(user?.role ?? 'Member'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user?.email ?? '—',
                          style: AppTypography.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),
            const Text('YOUR ACTIVITY', style: AppTypography.sectionLabel),
            const SizedBox(height: 10),
            bookingsAsync.when(
              data: (data) => _StatRow(
                upcoming: data.upcoming.length,
                total: data.upcoming.length + data.past.length,
              ),
              loading: () => const _StatRow(upcoming: 0, total: 0, isLoading: true),
              error: (_, __) => const _StatRow(upcoming: 0, total: 0),
            ),

            const SizedBox(height: 26),
            const Text('SETTINGS', style: AppTypography.sectionLabel),
            const SizedBox(height: 10),
            _SettingRow(
              label: 'Bookings',
              meta: 'Manage your slots',
              onTap: () => context.push(AppRoutes.bookings),
            ),
            _SettingRow(
              label: 'About',
              meta: 'Version 1.0.0',
              onTap: () => _showAboutSheet(context),
            ),
            _SettingRow(
              label: 'Sign out',
              meta: 'End your session',
              destructive: true,
              onTap: () => _confirmSignOut(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Eyebrow('About'),
              const SizedBox(height: 6),
              Text('Club Manager', style: AppTypography.display.copyWith(fontSize: 22)),
              const SizedBox(height: 12),
              Text(
                'A booking app for clubs and venues. Built with Flutter, '
                'connected to a .NET 8 backend with JWT auth and SQLite.',
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: 18),
              const Text('VERSION', style: AppTypography.sectionLabel),
              const SizedBox(height: 4),
              Text('1.0.0', style: AppTypography.body),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Eyebrow('Sign out'),
              const SizedBox(height: 6),
              Text(
                'End this session?',
                style: AppTypography.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'You will need to sign in again to manage bookings.',
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(authNotifierProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Sign out'),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Stay signed in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.upcoming,
    required this.total,
    this.isLoading = false,
  });

  final int upcoming;
  final int total;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(eyebrow: 'Upcoming', value: '$upcoming', sub: 'slots booked', isLoading: isLoading)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(eyebrow: 'All-time', value: '$total', sub: 'bookings made', isLoading: isLoading)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.eyebrow,
    required this.value,
    required this.sub,
    this.isLoading = false,
  });

  final String eyebrow;
  final String value;
  final String sub;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          const SizedBox(height: 8),
          Text(
            isLoading ? '–' : value,
            style: AppTypography.stat.copyWith(
              fontFamily: 'Fraunces',
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(sub, style: AppTypography.meta),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.meta,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final String meta;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    final metaColor = destructive
        ? AppColors.error.withOpacity(0.65)
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.title.copyWith(fontSize: 14, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(meta, style: AppTypography.meta.copyWith(color: metaColor)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: color.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
