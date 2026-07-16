import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shifting_wallah_driver/features/auth/presentation/login_screen.dart';
import 'package:shifting_wallah_driver/features/auth/presentation/splash_screen.dart';
import 'package:shifting_wallah_driver/features/bookings/presentation/assigned_bookings_screen.dart';
import 'package:shifting_wallah_driver/features/dashboard/presentation/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: AppRoutes.bookings,
      builder: (_, _) => const AssignedBookingsScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.bookings}/:id',
      builder: (_, state) => BookingDetailsPlaceholder(
        bookingId: state.pathParameters['id'] ?? '',
      ),
    ),
  ],
);

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const bookings = '/bookings';
}

extension AppNavigation on BuildContext {
  void goToLogin() => go(AppRoutes.login);
  void goToHome() => go(AppRoutes.home);
  void goToBookings() => go(AppRoutes.bookings);
  void goToBookingDetails(String id) => push('${AppRoutes.bookings}/$id');
}
