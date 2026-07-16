import 'package:dio/dio.dart';
import 'package:shifting_wallah_driver/core/storage/secure_storage_service.dart';
import 'package:shifting_wallah_driver/features/auth/data/driver_auth_repository.dart';

class DriverAuthService {
  const DriverAuthService(this._repository, this._storage);

  final DriverAuthRepository _repository;
  final SecureStorageService _storage;

  Future<void> login({required String email, required String password}) async {
    final token = await _repository.login(email: email, password: password);
    await _storage.saveToken(token);
  }

  Future<bool> logout() async {
    try {
      await _repository.logout();
      await _storage.deleteToken();
      return false;
    } on DioException {
      await _storage.deleteToken();
      return true;
    }
  }
}
