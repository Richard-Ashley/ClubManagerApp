import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/motion.dart';
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

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return SectionLabel('All venues — ${venues.length}');
            }
            final i = index - 1;
            final venue = venues[i];
            return StaggeredEntrance(
              index: i,
              child: _VenueRow(venue: venue),
            );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PressableScale(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => VenueDetailScreen(
                venueId: venue.id,
                venueName: venue.name,
              ),
              transitionDuration: const Duration(milliseconds: 320),
              reverseTransitionDuration: const Duration(milliseconds: 240),
              transitionsBuilder: (_, animation, __, child) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Stack(
          children: [
            if (venue.isActive)
              Positioned(
                left: 0,
                top: 16,
                bottom: 16,
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
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'venue-name-${venue.id}',
                          flightShuttleBuilder: (_, __, ___, ____, _____) =>
                              Material(
                            color: Colors.transparent,
                            child: Text(venue.name, style: AppTypography.title),
                          ),
                          child: Text(venue.name, style: AppTypography.title),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          venue.description.isEmpty ? '—' : venue.description,
                          style: AppTypography.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusPill(
                    venue.isActive ? 'View slots' : 'Closed',
                    muted: !venue.isActive,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
