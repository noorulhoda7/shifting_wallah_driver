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
