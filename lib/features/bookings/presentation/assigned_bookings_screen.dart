import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/app/router.dart';
import 'package:shifting_wallah_driver/core/network/dio_provider.dart';
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
  Widget build(BuildContext context) => BookingDetailsScreen(bookingId);
}

final bookingDetailsProvider = FutureProvider.family<BookingDetails?, String>(
  (ref, id) => AssignedBookingsRepository(
    DioProvider().createClient(),
  ).fetchBookingDetails(id),
);

final _bookingWorkflowStateProvider =
    StateProvider.family<AsyncValue<void>, String>(
      (_, _) => const AsyncData(null),
    );

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen(this.bookingId, {super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingDetailsProvider(bookingId));
    return ResponsiveScaffold(
      title: 'Booking Details',
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(bookingDetailsProvider(bookingId)),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _MessageState(
          text: error.toString(),
          action: 'Retry',
          onPressed: () => ref.invalidate(bookingDetailsProvider(bookingId)),
        ),
        data: (booking) => booking == null
            ? const _MessageState(text: 'Booking details not found.')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(bookingDetailsProvider(bookingId).future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.bookingNumber,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        _StatusBadge(booking.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DetailTile('Customer Name', booking.customerName),
                    _DetailTile('Customer Phone', booking.customerPhone),
                    _DetailTile('Pickup Address', booking.pickupAddress),
                    _DetailTile('Pickup Floor', booking.pickupFloor),
                    _DetailTile(
                      'Destination Address',
                      booking.destinationAddress,
                    ),
                    _DetailTile('Destination Floor', booking.destinationFloor),
                    _DetailTile('Service', booking.service),
                    _DetailTile('Vehicle', booking.vehicle),
                    _DetailTile('Move Date', booking.moveDate),
                    _DetailTile('Move Time', booking.moveTime),
                    _DetailTile(
                      'Priority Move',
                      booking.priorityMove ? 'Yes' : 'No',
                    ),
                    _DetailTile('Estimated Price', booking.estimatedPrice),
                    _DetailTile('Notes', booking.notes),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call),
                            label: const Text('Call Customer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.navigation),
                            label: const Text('Navigation'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _WorkflowButton(booking: booking),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value.isEmpty ? '-' : value),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final String status;

  @override
  Widget build(BuildContext context) => Chip(label: Text(status));
}

class _WorkflowButton extends StatelessWidget {
  const _WorkflowButton({required this.booking});

  final BookingDetails booking;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final action = _actionFor(booking.status);
        final state = ref.watch(_bookingWorkflowStateProvider(booking.id));
        if (action == null) {
          return const Center(child: _StatusBadge('Completed'));
        }
        return FilledButton(
          onPressed: state.isLoading
              ? null
              : () => _runWorkflow(context, ref, booking.id, action),
          child: state.isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_labelFor(action)),
        );
      },
    );
  }

  BookingWorkflowAction? _actionFor(String status) {
    return switch (status.toLowerCase().replaceAll('_', ' ')) {
      'assigned' => BookingWorkflowAction.accept,
      'accepted' => BookingWorkflowAction.start,
      'on going' || 'ongoing' => BookingWorkflowAction.complete,
      'completed' => null,
      _ => BookingWorkflowAction.accept,
    };
  }

  String _labelFor(BookingWorkflowAction action) {
    return switch (action) {
      BookingWorkflowAction.accept => 'Accept Booking',
      BookingWorkflowAction.start => 'Start Move',
      BookingWorkflowAction.complete => 'Complete Move',
    };
  }

  Future<void> _runWorkflow(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
    BookingWorkflowAction action,
  ) async {
    final notifier = ref.read(
      _bookingWorkflowStateProvider(bookingId).notifier,
    );
    notifier.state = const AsyncLoading();
    try {
      await AssignedBookingsRepository(
        DioProvider().createClient(),
      ).runWorkflow(bookingId, action);
      ref.invalidate(bookingDetailsProvider(bookingId));
      notifier.state = const AsyncData(null);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_labelFor(action)} successful')),
      );
    } catch (error, stackTrace) {
      notifier.state = AsyncError(error, stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _runWorkflow(context, ref, bookingId, action),
          ),
        ),
      );
    }
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.text, this.action, this.onPressed});

  final String text;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, textAlign: TextAlign.center),
        if (action != null) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: onPressed, child: Text(action!)),
        ],
      ],
    ),
  );
}
