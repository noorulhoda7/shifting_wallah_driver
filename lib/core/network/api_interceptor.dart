import 'package:dio/dio.dart';
import 'package:shifting_wallah_driver/core/storage/secure_storage_service.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }
}
