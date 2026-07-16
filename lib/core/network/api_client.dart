import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../security/secure_storage_service.dart';
import 'api_exception.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage).dio;
});

class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final token = await _storage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (_) {
                await _storage.clearTokens();
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final SecureStorageService _storage;
  late final Dio _dio;

  Dio get dio => _dio;

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static ApiException parseError(DioException error) {
    final response = error.response;
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      return ApiException(
        message: data['message'] as String? ?? 'Something went wrong',
        statusCode: response.statusCode,
        code: data['code'] as String?,
      );
    }
    return ApiException(
      message: error.message ?? 'Network error. Please try again.',
      statusCode: response?.statusCode,
    );
  }
}
