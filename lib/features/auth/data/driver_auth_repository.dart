import 'package:dio/dio.dart';
import 'package:shifting_wallah_driver/core/constants/api_endpoints.dart';
import 'package:shifting_wallah_driver/core/network/api_client.dart';

class DriverAuthRepository {
  const DriverAuthRepository(this._client);

  final ApiClient _client;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final token = data?['token'] ?? data?['access_token'];
      if (token is String && token.isNotEmpty) return token;
      throw const DriverAuthException('Login succeeded without a token.');
    } on DioException catch (error) {
      throw DriverAuthException(_messageFrom(error));
    }
  }

  Future<void> logout() async {
    try {
      await _client.post<void>(ApiEndpoints.logout);
    } on DioException catch (error) {
      if (_isNetworkFailure(error)) rethrow;
      throw DriverAuthException(_messageFrom(error));
    }
  }

  bool _isNetworkFailure(DioException error) {
    return error.response == null ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Unable to login. Please check your details and try again.';
  }
}

class DriverAuthException implements Exception {
  const DriverAuthException(this.message);

  final String message;
}
