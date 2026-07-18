import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/app/router.dart';
import 'package:shifting_wallah_driver/core/network/dio_provider.dart';
import 'package:shifting_wallah_driver/features/auth/data/driver_auth_repository.dart';
import 'package:shifting_wallah_driver/features/auth/providers/driver_auth_provider.dart';
import 'package:shifting_wallah_driver/features/dashboard/data/driver_dashboard_repository.dart';
import 'package:shifting_wallah_driver/features/dashboard/providers/driver_dashboard_provider.dart';
import 'package:shifting_wallah_driver/shared/widgets/responsive_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(driverAuthProvider);
    final dashboardState = ref.watch(driverDashboardProvider);

    return ResponsiveScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(driverDashboardProvider),
          icon: const Icon(Icons.refresh),
        ),
        TextButton(
          onPressed: context.goToBookings,
          child: const Text('Bookings'),
        ),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () async {
                  final notifier = ref.read(driverAuthProvider.notifier);
                  await notifier.logout();
                  final next = ref.read(driverAuthProvider);
                  if (!context.mounted) return;
                  if (next.error case final DriverAuthException error) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                    return;
                  }
                  final localOnly = notifier.loggedOutLocally;
                  ref.invalidate(driverAuthProvider);
                  context.goToLogin();
                  if (localOnly) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out locally.')),
                    );
                  }
                },
          child: authState.isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Logout'),
        ),
      ],
      child: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DashboardError(
          message: error.toString(),
          onRetry: () => ref.invalidate(driverDashboardProvider),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () => ref.refresh(driverDashboardProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _ProfileHeader(dashboard),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(_availabilityUpdateProvider);
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Availability'),
                    subtitle: Text(
                      _isOnline(dashboard.availability) ? 'Online' : 'Offline',
                    ),
                    value: _isOnline(dashboard.availability),
                    onChanged: state.isLoading
                        ? null
                        : (value) => _updateAvailability(context, ref, value),
                    secondary: state.isLoading
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isOnline(dashboard.availability)
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip('Assigned', dashboard.assignedCount),
                  _MetricChip('Accepted', dashboard.acceptedCount),
                  _MetricChip('Ongoing', dashboard.ongoingCount),
                  _MetricChip('Completed Today', dashboard.completedTodayCount),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Latest bookings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (dashboard.latestBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No bookings assigned yet.')),
                )
              else
                ...dashboard.latestBookings.map(_BookingTile.new),
            ],
          ),
        ),
      ),
    );
  }
}

final _availabilityUpdateProvider = StateProvider<AsyncValue<void>>(
  (_) => const AsyncData(null),
);

bool _isOnline(String value) {
  final text = value.toLowerCase();
  return text == 'online' || text == 'available' || text == '1';
}

Future<void> _updateAvailability(
  BuildContext context,
  WidgetRef ref,
  bool online,
) async {
  final notifier = ref.read(_availabilityUpdateProvider.notifier);
  notifier.state = const AsyncLoading();
  try {
    await DriverDashboardRepository(
      DioProvider().createClient(),
    ).updateAvailability(online);
    ref.invalidate(driverDashboardProvider);
    notifier.state = const AsyncData(null);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(online ? 'You are online.' : 'You are offline.')),
    );
  } catch (error, stackTrace) {
    notifier.state = AsyncError(error, stackTrace);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => _updateAvailability(context, ref, online),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader(this.dashboard);

  final DriverDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 32,
          child: Text(
            dashboard.driverName.isEmpty
                ? 'D'
                : dashboard.driverName.characters.first.toUpperCase(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dashboard.driverName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              _ProfileLine(Icons.badge, 'Driver ID', dashboard.driverId),
              _ProfileLine(Icons.email, 'Email', dashboard.email),
              _ProfileLine(Icons.phone, 'Phone', dashboard.phone),
              _ProfileLine(Icons.local_shipping, 'Vehicle', dashboard.vehicle),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text('$label: ${value.isEmpty ? '-' : value}'),
      ],
    ),
  );
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Chip(label: Text('$label: $value'));
}

class _BookingTile extends StatelessWidget {
  const _BookingTile(this.booking);

  final DriverBookingSummary booking;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(booking.title),
      subtitle: Text(booking.date.isEmpty ? booking.status : booking.date),
      trailing: Text(booking.status),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
