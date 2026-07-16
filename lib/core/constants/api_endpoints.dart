abstract final class ApiEndpoints {
  static const login = '/api/driver/login';
  static const logout = '/driver/logout';
  static const me = '/driver/me';
  static const bookings = '/driver/bookings';
  static const availability = '/driver/availability';

  static String bookingDetails(String bookingId) =>
      '/driver/bookings/$bookingId';

  static String accept(String bookingId) =>
      '/driver/bookings/$bookingId/accept';

  static String start(String bookingId) => '/driver/bookings/$bookingId/start';

  static String complete(String bookingId) =>
      '/driver/bookings/$bookingId/complete';
}
