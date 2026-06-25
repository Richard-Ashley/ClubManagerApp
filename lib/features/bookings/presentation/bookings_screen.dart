import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/extensions/extensions.dart';
import '../../../shared/widgets/date_block.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/auth_state.dart';
import '../domain/booking_models.dart';
import '../providers/booking_providers.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsBucketedProvider);
    final auth = ref.watch(authNotifierProvider);
    final userName = auth is AuthAuthenticated ? auth.user.fullName : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              onRefresh: () => ref.refresh(myBookingsProvider.future),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                    sliver: SliverToBoxAdapter(
                      child: ScreenHeader(
                        eyebrow: 'Bookings',
                        title: 'Your slots,\nyour days.',
                        trailing: GestureDetector(
                          onTap: () => context.push(AppRoutes.profile),
                          child: InitialsAvatar(userName),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    sliver: SliverToBoxAdapter(
                      child: bookingsAsync.when(
                        data: (data) => _AnimatedSummary(
                          upcoming: data.upcoming.length,
                          total: data.upcoming.length + data.past.length,
                        ),
                        loading: () => const SizedBox(height: 80),
                        error: (_, __) => const SizedBox(height: 0),
                      ),
                    ),
                  ),
                  bookingsAsync.when(
                    data: (data) => _BookingsList(upcoming: data.upcoming, past: data.past),
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: LoadingIndicator(),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorView(
                        message: e.toString(),
                        onRetry: () => ref.refresh(myBookingsProvider),
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
                ],
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: _BookSlotButton(
                onPressed: () async {
                  await context.push(AppRoutes.newBooking);
                  ref.invalidate(myBookingsProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSummary extends StatelessWidget {
  const _AnimatedSummary({required this.upcoming, required this.total});
  final int upcoming;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderStrong, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _AnimatedStat(value: upcoming, label: 'Upcoming'),
          const SizedBox(width: 28),
          _AnimatedStat(value: total, label: 'In total'),
        ],
      ),
    );
  }
}

class _AnimatedStat extends StatelessWidget {
  const _AnimatedStat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedNumber(value: value, style: AppTypography.stat),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.meta),
      ],
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.upcoming, required this.past});
  final List<Booking> upcoming;
  final List<Booking> past;

  @override
  Widget build(BuildContext context) {
    if (upcoming.isEmpty && past.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          message: 'No bookings yet. Tap below to reserve your first slot.',
        ),
      );
    }

    final children = <Widget>[];
    var index = 0;

    if (upcoming.isNotEmpty) {
      children.add(SectionLabel('Upcoming — ${upcoming.length}'));
      for (final booking in upcoming) {
        children.add(StaggeredEntrance(
          index: index++,
          child: _BookingRow(booking: booking, isUpcoming: true),
        ));
      }
    }
    if (past.isNotEmpty) {
      children.add(const SectionLabel('Past'));
      for (final booking in past) {
        children.add(StaggeredEntrance(
          index: index++,
          child: _BookingRow(booking: booking, isUpcoming: false),
        ));
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverList(delegate: SliverChildListDelegate(children)),
    );
  }
}

class _BookingRow extends ConsumerWidget {
  const _BookingRow({required this.booking, required this.isUpcoming});
  final Booking booking;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = booking.isCancelled ? AppColors.textSecondary : AppColors.success;
    final statusBg = booking.isCancelled ? AppColors.border : const Color(0x1A1D9E75);
    final canCancel = isUpcoming && booking.isConfirmed;

    final card = Stack(
      children: [
        if (canCancel)
          Positioned(
            left: 0,
            top: 14,
            bottom: 14,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.venueName, style: AppTypography.title),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.dayOfWeek} · ${booking.timeRange}',
                      style: AppTypography.bodyMuted,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: AppTypography.pill.copyWith(color: statusColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DateBlock(date: booking.bookingDateTime),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: canCancel
          ? PressableScale(
              onTap: () => _showCancelSheet(context, ref),
              child: card,
            )
          : card,
    );
  }

  void _showCancelSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
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
              const Eyebrow('Cancel booking'),
              const SizedBox(height: 6),
              Text(
                'Release this slot?',
                style: AppTypography.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                '${booking.venueName} on ${booking.dayOfWeek}, ${booking.timeRange}.',
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await ref.read(bookingRepositoryProvider).cancel(booking.id);
                    ref.invalidate(myBookingsProvider);
                    if (context.mounted) context.showSnackBar('Booking cancelled.');
                  } catch (e) {
                    if (context.mounted) context.showErrorSnackBar(e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Cancel booking'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Keep it'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookSlotButton extends StatelessWidget {
  const _BookSlotButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      scale: 0.97,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 18, color: AppColors.surface),
            SizedBox(width: 8),
            Text(
              'Book a new slot',
              style: TextStyle(
                color: AppColors.surface,
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
