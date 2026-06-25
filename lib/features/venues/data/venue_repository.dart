import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/venue_models.dart';

class VenueRepository {
  const VenueRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Venue>> getAll() {
    return _apiClient.get<List<Venue>>(
      ApiEndpoints.venues,
      fromJson: (data) => (data as List)
          .map((e) => Venue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Venue> getById(int id) {
    return _apiClient.get<Venue>(
      ApiEndpoints.venue(id),
      fromJson: (data) => Venue.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<VenueSlot>> getSlots(int venueId) {
    return _apiClient.get<List<VenueSlot>>(
      ApiEndpoints.venueSlots(venueId),
      fromJson: (data) => (data as List)
          .map((e) => VenueSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
