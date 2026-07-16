import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_storage_service.dart';
import '../domain/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  AuthRepository({
    required Dio dio,
    required SecureStorageService storage,
  })  : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      const user = User(
        id: 'user_001',
        name: 'Demo Investor',
        email: 'demo@growwealth.in',
        phone: '+91 98765 43210',
        pan: 'ABCDE1234F',
        kycStatus: KycStatus.verified,
      );
      await _storage.saveTokens(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
      );
      await _storage.saveUserId(user.id);
      return user;
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await _storage.saveUserId(user.id);
      return user;
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<User> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        kycStatus: KycStatus.pending,
        createdAt: DateTime.now(),
      );
      await _storage.saveTokens(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
      );
      await _storage.saveUserId(user.id);
      return user;
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );
      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await _storage.saveUserId(user.id);
      return user;
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<User?> getCurrentUser() async {
    final hasSession = await _storage.hasValidSession();
    if (!hasSession) return null;

    if (AppConfig.useMockData) {
      return const User(
        id: 'user_001',
        name: 'Demo Investor',
        email: 'demo@growwealth.in',
        phone: '+91 98765 43210',
        pan: 'ABCDE1234F',
        kycStatus: KycStatus.verified,
      );
    }

    try {
      final response = await _dio.get(ApiEndpoints.profile);
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      await _storage.clearTokens();
      return null;
    }
  }

  Future<void> logout() async {
    if (!AppConfig.useMockData) {
      try {
        await _dio.post(ApiEndpoints.logout);
      } catch (_) {}
    }
    await _storage.clearTokens();
  }
}
