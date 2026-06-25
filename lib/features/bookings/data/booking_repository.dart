import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/booking_models.dart';

class BookingRepository {
  const BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Booking>> getMyBookings() {
    return _apiClient.get<List<Booking>>(
      ApiEndpoints.myBookings,
      fromJson: (data) => (data as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Booking> create(CreateBookingRequest request) {
    return _apiClient.post<Booking>(
      ApiEndpoints.bookings,
      data: request.toJson(),
      fromJson: (data) => Booking.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> cancel(int bookingId) {
    return _apiClient.delete(ApiEndpoints.booking(bookingId));
  }
}
