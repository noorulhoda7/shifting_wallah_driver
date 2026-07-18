import 'package:shifting_wallah_driver/core/constants/api_endpoints.dart';
import 'package:shifting_wallah_driver/core/network/api_client.dart';

class DriverDashboardRepository {
  const DriverDashboardRepository(this._client);

  final ApiClient _client;

  Future<DriverDashboard> fetchDashboard() async {
    final results = await Future.wait([
      _client.get<Map<String, dynamic>>(ApiEndpoints.me),
      _client.get<Map<String, dynamic>>(ApiEndpoints.bookings),
    ]);
    return DriverDashboard.fromJson(
      results.first.data ?? {},
      results.last.data ?? {},
    );
  }

  Future<void> updateAvailability(bool online) {
    return _client.post<void>(
      ApiEndpoints.availability,
      data: {'availability': online ? 'online' : 'offline'},
    );
  }
}

class DriverDashboard {
  const DriverDashboard({
    required this.driverName,
    required this.email,
    required this.phone,
    required this.vehicle,
    required this.driverId,
    required this.availability,
    required this.assignedCount,
    required this.acceptedCount,
    required this.ongoingCount,
    required this.completedTodayCount,
    required this.latestBookings,
  });

  final String driverName;
  final String email;
  final String phone;
  final String vehicle;
  final String driverId;
  final String availability;
  final int assignedCount;
  final int acceptedCount;
  final int ongoingCount;
  final int completedTodayCount;
  final List<DriverBookingSummary> latestBookings;

  factory DriverDashboard.fromJson(
    Map<String, dynamic> me,
    Map<String, dynamic> bookingsPayload,
  ) {
    final driver = _map(me['data']) ?? me;
    final bookings = _bookingsFrom(bookingsPayload);
    final counts =
        _map(bookingsPayload['counts']) ??
        _map(bookingsPayload['summary']) ??
        bookingsPayload;

    int count(String status) => bookings
        .where((booking) => booking.status.toLowerCase() == status)
        .length;

    return DriverDashboard(
      driverName: '${driver['name'] ?? driver['driver_name'] ?? 'Driver'}',
      email: '${driver['email'] ?? '-'}',
      phone: '${driver['phone'] ?? driver['mobile'] ?? '-'}',
      vehicle: '${driver['vehicle'] ?? driver['vehicle_type'] ?? '-'}',
      driverId: '${driver['driver_id'] ?? driver['id'] ?? '-'}',
      availability:
          '${driver['availability'] ?? driver['status'] ?? 'offline'}',
      assignedCount: _int(counts['assigned_count']) ?? count('assigned'),
      acceptedCount: _int(counts['accepted_count']) ?? count('accepted'),
      ongoingCount: _int(counts['ongoing_count']) ?? count('ongoing'),
      completedTodayCount:
          _int(counts['completed_today_count']) ??
          bookings
              .where(
                (booking) =>
                    booking.status.toLowerCase() == 'completed' &&
                    booking.date ==
                        DateTime.now().toIso8601String().split('T').first,
              )
              .length,
      latestBookings: bookings.take(5).toList(),
    );
  }
}

class DriverBookingSummary {
  const DriverBookingSummary({
    required this.title,
    required this.status,
    required this.date,
  });

  final String title;
  final String status;
  final String date;

  factory DriverBookingSummary.fromJson(Map<String, dynamic> json) {
    return DriverBookingSummary(
      title: '${json['customer_name'] ?? json['booking_id'] ?? 'Booking'}',
      status: '${json['status'] ?? 'assigned'}',
      date:
          '${json['date'] ?? json['scheduled_date'] ?? json['created_at'] ?? ''}'
              .split('T')
              .first,
    );
  }
}

Map<String, dynamic>? _map(Object? value) =>
    value is Map<String, dynamic> ? value : null;

List<Map<String, dynamic>> _list(Object? value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

List<DriverBookingSummary> _bookingsFrom(Map<String, dynamic> payload) {
  final data = payload['data'];
  final value = data is Map<String, dynamic>
      ? data['data'] ?? data['bookings']
      : data ?? payload['bookings'];
  return _list(value).map(DriverBookingSummary.fromJson).toList();
}

int? _int(Object? value) => value is int ? value : int.tryParse('$value');
