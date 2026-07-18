abstract final class ApiEndpoints {
  static const login = '/api/driver/login';
  static const logout = '/api/driver/logout';
  static const me = '/api/driver/me';
  static const bookings = '/api/driver/bookings';
  static const availability = '/driver/availability';

  static String bookingDetails(String bookingId) =>
      '/api/driver/bookings/$bookingId';

  static String accept(String bookingId) =>
      '/api/driver/bookings/$bookingId/accept';

  static String start(String bookingId) =>
      '/api/driver/bookings/$bookingId/start';

  static String complete(String bookingId) =>
      '/api/driver/bookings/$bookingId/complete';
}
