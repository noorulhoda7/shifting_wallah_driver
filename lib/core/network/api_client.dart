import 'package:dio/dio.dart';

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(String path, {Object? data, Options? options}) {
    return _dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(String path, {Options? options}) {
    return _dio.delete<T>(path, options: options);
  }
}
