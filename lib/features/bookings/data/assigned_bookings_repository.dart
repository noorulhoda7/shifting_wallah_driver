import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/core/constants/api_endpoints.dart';
import 'package:shifting_wallah_driver/core/network/api_client.dart';
import 'package:shifting_wallah_driver/core/network/dio_provider.dart';

final assignedBookingsProvider = FutureProvider<List<AssignedBooking>>(
  (ref) => AssignedBookingsRepository(
    DioProvider().createClient(),
  ).fetchAssignedBookings(),
);

class AssignedBookingsRepository {
  const AssignedBookingsRepository(this._client);

  final ApiClient _client;

  Future<List<AssignedBooking>> fetchAssignedBookings() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.bookings,
    );
    return _extractBookings(
      response.data ?? {},
    ).map(AssignedBooking.fromJson).toList();
  }
}

class AssignedBooking {
  const AssignedBooking({
    required this.id,
    required this.bookingNumber,
    required this.customerName,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.moveDate,
    required this.moveTime,
    required this.status,
    required this.vehicle,
    required this.service,
    required this.estimatedPrice,
    required this.priorityMove,
  });

  final String id;
  final String bookingNumber;
  final String customerName;
  final String pickupAddress;
  final String destinationAddress;
  final String moveDate;
  final String moveTime;
  final String status;
  final String vehicle;
  final String service;
  final String estimatedPrice;
  final bool priorityMove;

  factory AssignedBooking.fromJson(Map<String, dynamic> json) {
    String text(String a, [String? b, String fallback = '-']) =>
        '${json[a] ?? (b == null ? null : json[b]) ?? fallback}';
    final moveAt = text('move_date', 'scheduled_date', '');
    return AssignedBooking(
      id: text('id', 'booking_id', text('booking_number', fallback: '')),
      bookingNumber: text('booking_number', 'booking_no', text('id')),
      customerName: text('customer_name', 'customer'),
      pickupAddress: text('pickup_address', 'pickup'),
      destinationAddress: text('destination_address', 'drop_address'),
      moveDate: moveAt.split('T').first,
      moveTime: text('move_time', 'scheduled_time', _timeFrom(moveAt)),
      status: text('status', fallback: 'assigned'),
      vehicle: text('vehicle', 'vehicle_type'),
      service: text('service', 'service_type'),
      estimatedPrice: text('estimated_price', 'estimate_price'),
      priorityMove: json['priority_move'] == true || json['priority'] == true,
    );
  }

  bool matches(String query, String statusFilter) {
    final text = [
      bookingNumber,
      customerName,
      pickupAddress,
      destinationAddress,
      status,
      vehicle,
      service,
    ].join(' ').toLowerCase();
    final statusOk =
        statusFilter == 'All' ||
        status.toLowerCase() == statusFilter.toLowerCase();
    return statusOk && text.contains(query.trim().toLowerCase());
  }
}

List<Map<String, dynamic>> _extractBookings(Map<String, dynamic> payload) {
  final data = payload['data'];
  final value = data is Map<String, dynamic>
      ? data['data'] ?? data['bookings']
      : data ?? payload['bookings'];
  return value is List ? value.whereType<Map<String, dynamic>>().toList() : [];
}

String _timeFrom(String value) {
  final parts = value.split('T');
  return parts.length > 1 ? parts.last.split('.').first : '';
}
