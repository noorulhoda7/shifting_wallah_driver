import 'package:dio/dio.dart';
import 'package:shifting_wallah_driver/core/config/app_config.dart';
import 'package:shifting_wallah_driver/core/network/api_client.dart';
import 'package:shifting_wallah_driver/core/network/api_interceptor.dart';
import 'package:shifting_wallah_driver/core/storage/secure_storage_service.dart';

class DioProvider {
  DioProvider({SecureStorageService? storage})
    : _storage = storage ?? SecureStorageService();

  final SecureStorageService _storage;

  Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        contentType: Headers.jsonContentType,
      ),
    );

    dio.interceptors.add(ApiInterceptor(_storage));
    return dio;
  }

  ApiClient createClient() => ApiClient(createDio());
}
