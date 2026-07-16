import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/core/network/dio_provider.dart';
import 'package:shifting_wallah_driver/features/dashboard/data/driver_dashboard_repository.dart';

final _dashboardRepositoryProvider = Provider(
  (ref) => DriverDashboardRepository(DioProvider().createClient()),
);

final driverDashboardProvider = FutureProvider<DriverDashboard>(
  (ref) => ref.watch(_dashboardRepositoryProvider).fetchDashboard(),
);
