import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

class DioClient {
  final Dio dio;
  final SecureStorageService secureStorage;

  DioClient({
    required this.dio,
    required this.secureStorage,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final req = e.requestOptions;
              final token = await secureStorage.readAccessToken();
              if (token != null && token.isNotEmpty) {
                req.headers['Authorization'] = 'Bearer $token';
              }
              try {
                final res = await dio.fetch(req);
                handler.resolve(res);
                return;
              } catch (e2) {
                handler.reject(e2 is DioException ? e2 : DioException(requestOptions: req));
                return;
              }
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = await secureStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final res = await dio.post('/auth/refresh', data: {'refresh_token': refresh});
      final data = res.data as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;
      if (access == null || access.isEmpty) return false;
      await secureStorage.writeAccessToken(access);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await secureStorage.writeRefreshToken(newRefresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
