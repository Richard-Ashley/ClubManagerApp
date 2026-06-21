class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login    = '/auth/login';
  static const String register = '/auth/register';

  // Members
  static const String members  = '/members';
  static String member(int id) => '/members/$id';

  // Venues
  static const String venues   = '/venues';
  static String venue(int id)  => '/venues/$id';
  static String venueSlots(int id) => '/venues/$id/slots';
  static String toggleVenueActive(int id) => '/venues/$id/toggle-active';

  // Bookings
  static const String bookings   = '/bookings';
  static const String myBookings = '/bookings/my';
  static String booking(int id)  => '/bookings/$id';
}
