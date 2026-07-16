import 'package:flutter/material.dart';
import 'package:shifting_wallah_driver/shared/widgets/responsive_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Home',
      child: Center(
        child: Text(
          'Home placeholder',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
