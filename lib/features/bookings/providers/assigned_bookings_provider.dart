import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/core/network/dio_provider.dart';
import 'package:shifting_wallah_driver/features/bookings/data/assigned_bookings_repository.dart';

final _assignedBookingsRepositoryProvider = Provider(
  (ref) => AssignedBookingsRepository(DioProvider().createClient()),
);

final assignedBookingsProvider = FutureProvider<List<AssignedBooking>>(
  (ref) =>
      ref.watch(_assignedBookingsRepositoryProvider).fetchAssignedBookings(),
);
