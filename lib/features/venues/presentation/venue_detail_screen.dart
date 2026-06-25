import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../domain/venue_models.dart';
import '../providers/venue_providers.dart';

class VenueDetailScreen extends ConsumerWidget {
  const VenueDetailScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  final int venueId;
  final String venueName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(venueSlotsProvider(venueId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Venue'),
                    const SizedBox(height: 6),
                    Hero(
                      tag: 'venue-name-$venueId',
                      flightShuttleBuilder: (_, __, ___, ____, _____) =>
                          Material(
                        color: Colors.transparent,
                        child: Text(venueName, style: AppTypography.display),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: DisplayHeadline(venueName),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            slotsAsync.when(
              data: (slots) => _SlotsSection(
                slots: slots,
                venueId: venueId,
                venueName: venueName,
              ),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingIndicator(),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.refresh(venueSlotsProvider(venueId)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotsSection extends StatelessWidget {
  const _SlotsSection({
    required this.slots,
    required this.venueId,
    required this.venueName,
  });

  final List<VenueSlot> slots;
  final int venueId;
  final String venueName;

  static const _dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(message: 'No slots configured for this venue.'),
      );
    }

    final grouped = <String, List<VenueSlot>>{};
    for (final slot in slots) {
      grouped.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
    }
    final days = grouped.keys.toList()
      ..sort((a, b) => _dayOrder.indexOf(a).compareTo(_dayOrder.indexOf(b)));

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${slots.length} slots',
                      style: AppTypography.meta.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    const MetaDot(),
                    const SizedBox(width: 8),
                    Text('${days.length} days', style: AppTypography.meta),
                  ],
                ),
              );
            }
            final dayIndex = index - 1;
            final day = days[dayIndex];
            final daySlots = grouped[day]!;
            return StaggeredEntrance(
              index: dayIndex,
              child: _DayBlock(day: day, slots: daySlots),
            );
          },
          childCount: days.length + 1,
        ),
      ),
    );
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock({required this.day, required this.slots});
  final String day;
  final List<VenueSlot> slots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(day),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                for (var i = 0; i < slots.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 0.5, color: AppColors.border),
                  _SlotRow(slot: slots[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot});
  final VenueSlot slot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(slot.timeRange, style: AppTypography.body),
          ),
          Text(
            'Available',
            style: AppTypography.meta.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
