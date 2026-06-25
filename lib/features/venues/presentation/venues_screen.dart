import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../shared/extensions/extensions.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/auth_state.dart';
import '../providers/venue_providers.dart';
import '../domain/venue_models.dart';
import 'venue_detail_screen.dart';

class VenuesScreen extends ConsumerWidget {
  const VenuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venuesProvider);
    final auth = ref.watch(authNotifierProvider);
    final userName = auth is AuthAuthenticated ? auth.user.fullName : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.refresh(venuesProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: ScreenHeader(
                    eyebrow: 'Venues',
                    title: 'Pick a place\nto play.',
                    trailing: InitialsAvatar(userName),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: SliverToBoxAdapter(
                  child: venuesAsync.when(
                    data: (venues) => SummaryStats(items: [
                      (
                        value: venues.where((v) => v.isActive).length.toString(),
                        label: 'Open today',
                      ),
                      (
                        value: venues.length.toString(),
                        label: 'In total',
                      ),
                    ]),
                    loading: () => const SizedBox(height: 80),
                    error: (_, __) => const SizedBox(height: 0),
                  ),
                ),
              ),
              venuesAsync.when(
                data: (venues) => _VenuesList(venues: venues),
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingIndicator(),
                ),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.refresh(venuesProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenuesList extends StatelessWidget {
  const _VenuesList({required this.venues});
  final List<Venue> venues;

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(message: 'No venues yet.'),
      );
    }

    final active = venues.where((v) => v.isActive).length;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return SectionLabel('All venues — ${venues.length}');
            }
            final venue = venues[index - 1];
            return _VenueRow(venue: venue);
          },
          childCount: venues.length + 1,
        ),
      ),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.venue});
  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      title: venue.name,
      subtitle: venue.description.isEmpty ? '—' : venue.description,
      isActive: venue.isActive,
      trailing: StatusPill(
        venue.isActive ? 'View slots' : 'Closed',
        muted: !venue.isActive,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VenueDetailScreen(venueId: venue.id, venueName: venue.name),
          ),
        );
      },
    );
  }
}
