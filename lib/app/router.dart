import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shifting_wallah_driver/features/auth/presentation/login_screen.dart';
import 'package:shifting_wallah_driver/features/auth/presentation/splash_screen.dart';
import 'package:shifting_wallah_driver/features/dashboard/presentation/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
  ],
);

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
}

extension AppNavigation on BuildContext {
  void goToLogin() => go(AppRoutes.login);
  void goToHome() => go(AppRoutes.home);
}
