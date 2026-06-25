import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../shared/extensions/extensions.dart';
import '../../../shared/widgets/date_block.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../venues/domain/venue_models.dart';
import '../../venues/providers/venue_providers.dart';
import '../domain/booking_models.dart';
import '../providers/booking_providers.dart';
import '../providers/new_booking_state.dart';

class NewBookingScreen extends ConsumerWidget {
  const NewBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newBookingProvider);

    final (eyebrow, headline) = switch (state.step) {
      1 => ('Step 1 of 3', 'Pick a venue\nto book.'),
      2 => ('Step 2 of 3', 'Pick a date\nthat works.'),
      _ => ('Step 3 of 3', 'Confirm your\nbooking.'),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () {
            if (state.step > 1) {
              ref.read(newBookingProvider.notifier).back();
            } else {
              context.pop();
            }
          },
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(eyebrow),
                  const SizedBox(height: 6),
                  DisplayHeadline(headline),
                  const SizedBox(height: 20),
                  StepIndicator(totalSteps: 3, currentStep: state.step),
                ],
              ),
            ),
            Expanded(
              child: switch (state.step) {
                1 => const _StepVenue(),
                2 => const _StepDate(),
                _ => const _StepConfirm(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1 — pick venue ──────────────────────────────────────────────────────

class _StepVenue extends ConsumerWidget {
  const _StepVenue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venuesProvider);

    return venuesAsync.when(
      data: (venues) {
        final active = venues.where((v) => v.isActive).toList();
        if (active.isEmpty) {
          return const EmptyStateView(message: 'No venues open right now.');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          itemCount: active.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) return const SectionLabel('Open venues');
            final venue = active[i - 1];
            return ListItemCard(
              title: venue.name,
              subtitle: venue.description.isEmpty ? '—' : venue.description,
              trailing: const Icon(Icons.arrow_forward, size: 18, color: AppColors.textPrimary),
              onTap: () => ref.read(newBookingProvider.notifier).pickVenue(venue),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.refresh(venuesProvider),
      ),
    );
  }
}

// ── Step 2 — pick date ───────────────────────────────────────────────────────

class _StepDate extends ConsumerWidget {
  const _StepDate();

  static const _dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newBookingProvider);
    final venue = state.venue!;
    final slotsAsync = ref.watch(venueSlotsProvider(venue.id));

    return slotsAsync.when(
      data: (slots) {
        if (slots.isEmpty) {
          return const EmptyStateView(message: 'No slots configured for this venue.');
        }

        // Compute next 12 candidate dates that match any slot's day-of-week
        final availableDays = slots.map((s) => s.dayOfWeek).toSet();
        final candidates = _nextDates(availableDays, count: 12);

        // Group candidate dates' available slots
        final selectedDate = state.date;
        final slotsForSelectedDate = selectedDate == null
            ? <VenueSlot>[]
            : slots.where((s) => s.dayOfWeek == _weekdayName(selectedDate)).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          children: [
            const SectionLabel('Venue'),
            ListItemCard(
              title: venue.name,
              subtitle: venue.description.isEmpty ? '—' : venue.description,
              trailing: TextButton(
                onPressed: () => ref.read(newBookingProvider.notifier).goToStep(1),
                child: const Text('Change'),
              ),
            ),
            const SectionLabel('Next available days'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemCount: candidates.length,
              itemBuilder: (_, i) {
                final date = candidates[i];
                final isSelected = selectedDate != null &&
                    selectedDate.year == date.year &&
                    selectedDate.month == date.month &&
                    selectedDate.day == date.day;
                return _DayPill(
                  date: date,
                  isSelected: isSelected,
                  onTap: () => ref.read(newBookingProvider.notifier).pickDate(date),
                );
              },
            ),
            if (selectedDate != null) ...[
              const SectionLabel('Available slots'),
              for (final slot in slotsForSelectedDate)
                _SelectableSlot(
                  slot: slot,
                  isSelected: state.slot?.id == slot.id,
                  onTap: () => ref.read(newBookingProvider.notifier).pickSlot(slot),
                ),
            ],
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.refresh(venueSlotsProvider(venue.id)),
      ),
    );
  }

  static List<DateTime> _nextDates(Set<String> dayNames, {required int count}) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final result = <DateTime>[];
    for (var i = 0; i < 60 && result.length < count; i++) {
      final candidate = start.add(Duration(days: i));
      if (dayNames.contains(_weekdayName(candidate))) {
        result.add(candidate);
      }
    }
    return result;
  }

  static String _weekdayName(DateTime date) =>
      _dayOrder[date.weekday - 1];
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.date, required this.isSelected, required this.onTap});
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.border,
              width: isSelected ? 1 : 0.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: DateBlock(date: date, size: DateBlockSize.small),
          ),
        ),
      ),
    );
  }
}

class _SelectableSlot extends StatelessWidget {
  const _SelectableSlot({required this.slot, required this.isSelected, required this.onTap});
  final VenueSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected ? AppColors.accentSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 1 : 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(slot.timeRange, style: AppTypography.body)),
                Text(
                  isSelected ? 'Selected' : 'Free',
                  style: AppTypography.meta.copyWith(
                    color: isSelected ? AppColors.accent : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 3 — confirm ─────────────────────────────────────────────────────────

class _StepConfirm extends ConsumerStatefulWidget {
  const _StepConfirm();

  @override
  ConsumerState<_StepConfirm> createState() => _StepConfirmState();
}

class _StepConfirmState extends ConsumerState<_StepConfirm> {
  bool _submitting = false;

  Future<void> _submit() async {
    final state = ref.read(newBookingProvider);
    setState(() => _submitting = true);
    try {
      final request = CreateBookingRequest(
        venueId: state.venue!.id,
        slotId: state.slot!.id,
        bookingDate: '${state.date!.year}-'
            '${state.date!.month.toString().padLeft(2, '0')}-'
            '${state.date!.day.toString().padLeft(2, '0')}',
      );
      await ref.read(bookingRepositoryProvider).create(request);
      ref.invalidate(myBookingsProvider);
      if (mounted) {
        context.showSnackBar('Booking confirmed.');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newBookingProvider);
    final venue = state.venue!;
    final slot = state.slot!;
    final date = state.date!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SectionLabel('Summary'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(venue.name, style: AppTypography.title.copyWith(fontSize: 20)),
                                const SizedBox(height: 2),
                                Text(venue.description, style: AppTypography.bodyMuted),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          DateBlock(date: date, size: DateBlockSize.large),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 14),
                      _DetailRow(label: 'Day', value: slot.dayOfWeek),
                      _DetailRow(label: 'Time', value: slot.timeRange),
                      _DetailRow(label: 'Date', value: date.toDisplayDate()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Confirm booking',
            isLoading: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: 6),
          AppButton(
            label: 'Back',
            variant: AppButtonVariant.text,
            onPressed: _submitting ? null : () => ref.read(newBookingProvider.notifier).back(),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMuted)),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }
}
