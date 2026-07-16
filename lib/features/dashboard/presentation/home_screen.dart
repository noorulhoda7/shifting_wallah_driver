import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/app/router.dart';
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
              Text(
                dashboard.driverName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('Availability: ${dashboard.availability}'),
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
