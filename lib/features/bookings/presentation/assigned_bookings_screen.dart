import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/app/router.dart';
import 'package:shifting_wallah_driver/features/bookings/data/assigned_bookings_repository.dart';
import 'package:shifting_wallah_driver/shared/widgets/responsive_scaffold.dart';

class AssignedBookingsScreen extends ConsumerStatefulWidget {
  const AssignedBookingsScreen({super.key});

  @override
  ConsumerState<AssignedBookingsScreen> createState() =>
      _AssignedBookingsScreenState();
}

class _AssignedBookingsScreenState
    extends ConsumerState<AssignedBookingsScreen> {
  String _query = '';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(assignedBookingsProvider);
    return ResponsiveScaffold(
      title: 'Assigned Bookings',
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(assignedBookingsProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: bookingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.invalidate(assignedBookingsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
        data: (bookings) {
          final statuses = [
            'All',
            ...{for (final b in bookings) b.status},
          ];
          final visible = bookings
              .where((booking) => booking.matches(_query, _status))
              .toList();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(assignedBookingsProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search bookings',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'All'),
                ),
                const SizedBox(height: 16),
                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No assigned bookings found.')),
                  )
                else
                  ...visible.map(_BookingCard.new),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard(this.booking);

  final AssignedBooking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.goToBookingDetails(booking.id),
        title: Text('${booking.bookingNumber} - ${booking.customerName}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Pickup: ${booking.pickupAddress}\n'
            'Destination: ${booking.destinationAddress}\n'
            'Move: ${booking.moveDate} ${booking.moveTime}\n'
            'Vehicle: ${booking.vehicle}\n'
            'Service: ${booking.service}\n'
            'Estimated Price: ${booking.estimatedPrice}\n'
            'Priority Move: ${booking.priorityMove ? 'Yes' : 'No'}',
          ),
        ),
        trailing: Text(booking.status),
      ),
    );
  }
}

class BookingDetailsPlaceholder extends StatelessWidget {
  const BookingDetailsPlaceholder({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
    title: 'Booking Details',
    child: Center(child: Text('Booking $bookingId')),
  );
}
