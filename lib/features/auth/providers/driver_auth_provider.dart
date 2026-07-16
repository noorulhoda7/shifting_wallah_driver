import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/core/network/dio_provider.dart';
import 'package:shifting_wallah_driver/core/storage/secure_storage_service.dart';
import 'package:shifting_wallah_driver/features/auth/application/driver_auth_service.dart';
import 'package:shifting_wallah_driver/features/auth/data/driver_auth_repository.dart';

final _storageProvider = Provider((_) => SecureStorageService());
final _apiClientProvider = Provider(
  (ref) => DioProvider(storage: ref.watch(_storageProvider)).createClient(),
);
final _authServiceProvider = Provider(
  (ref) => DriverAuthService(
    DriverAuthRepository(ref.watch(_apiClientProvider)),
    ref.watch(_storageProvider),
  ),
);

final driverAuthProvider =
    StateNotifierProvider<DriverAuthNotifier, AsyncValue<void>>(
      (ref) => DriverAuthNotifier(ref.watch(_authServiceProvider)),
    );

class DriverAuthNotifier extends StateNotifier<AsyncValue<void>> {
  DriverAuthNotifier(this._service) : super(const AsyncData(null));

  final DriverAuthService _service;
  bool loggedOutLocally = false;

  Future<void> login({required String email, required String password}) async {
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    if (emailError != null || passwordError != null) {
      state = AsyncError(emailError ?? passwordError!, StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.login(email: email.trim(), password: password),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      loggedOutLocally = await _service.logout();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }
}
