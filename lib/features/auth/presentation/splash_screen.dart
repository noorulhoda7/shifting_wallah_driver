import 'package:flutter/material.dart';
import 'package:shifting_wallah_driver/app/router.dart';
import 'package:shifting_wallah_driver/shared/widgets/responsive_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Shifting Wallah Driver',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlutterLogo(size: 72),
          const SizedBox(height: 24),
          Text('Driver App', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: context.goToLogin,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
