import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/config/app_constants.dart';

final authServiceProvider = Provider((ref) => AuthService(ref));
final userNameProvider = StateProvider<String>((ref) => "User");

class AuthService {
  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._ref);

  Future<Response> signup({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String role,
  }) async {
    final dio = _ref.read(apiClientProvider).dio;
    return await dio.post('/auth/signup', data: {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'role': role,
    });
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    final dio = _ref.read(apiClientProvider).dio;
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 && response.data['token'] != null) {
      await _storage.write(key: AppConstants.tokenKey, value: response.data['token']);
      _ref.read(userNameProvider.notifier).state = response.data['name'] ?? "User";
    }
    return response;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }
}
