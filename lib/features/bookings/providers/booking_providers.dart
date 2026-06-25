import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/booking_repository.dart';
import '../domain/booking_models.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient);
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getMyBookings();
});

/// Splits bookings into upcoming + past, each sorted appropriately.
final bookingsBucketedProvider = FutureProvider<({List<Booking> upcoming, List<Booking> past})>((ref) async {
  final bookings = await ref.watch(myBookingsProvider.future);

  final upcoming = bookings.where((b) => b.isUpcoming).toList()
    ..sort((a, b) => a.bookingDateTime.compareTo(b.bookingDateTime));

  final past = bookings.where((b) => !b.isUpcoming).toList()
    ..sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

  return (upcoming: upcoming, past: past);
});
