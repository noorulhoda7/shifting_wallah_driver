import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/app/router.dart';
import 'package:shifting_wallah_driver/features/auth/data/driver_auth_repository.dart';
import 'package:shifting_wallah_driver/features/auth/providers/driver_auth_provider.dart';
import 'package:shifting_wallah_driver/shared/widgets/responsive_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(driverAuthProvider);

    return ResponsiveScaffold(
      title: 'Home',
      actions: [
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
      child: Center(
        child: Text(
          'Home placeholder',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
