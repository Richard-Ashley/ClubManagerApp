import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/venue_repository.dart';
import '../domain/venue_models.dart';

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VenueRepository(apiClient);
});

final venuesProvider = FutureProvider<List<Venue>>((ref) {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getAll();
});

final venueSlotsProvider =
    FutureProvider.family<List<VenueSlot>, int>((ref, venueId) {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getSlots(venueId);
});
