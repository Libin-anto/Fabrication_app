import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final dio = Dio();

  // Production backend on Render (free tier can take 50s+ to cold-start)
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://fabrication-app.onrender.com',
  );

  dio.options.baseUrl = baseUrl;
  // Render free tier spins down after inactivity and can take 50s+ to cold start.
  // We set timeouts well above that so the first request after idle always succeeds.
  dio.options.connectTimeout = const Duration(seconds: 90);
  dio.options.receiveTimeout = const Duration(seconds: 90);
  dio.options.sendTimeout = const Duration(seconds: 90);

  // Auth interceptor — attaches Bearer token and retries once on timeout
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await secureStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException error, handler) async {
      // On connect/receive timeout, retry once automatically (handles cold starts)
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        try {
          final opts = error.requestOptions;
          final token = await secureStorage.getToken();
          final retryResponse = await dio.fetch(
            opts.copyWith(
              headers: {
                ...opts.headers,
                if (token != null) 'Authorization': 'Bearer $token',
              },
            ),
          );
          return handler.resolve(retryResponse);
        } catch (_) {
          // If retry also fails, pass the original error through
        }
      }
      return handler.next(error);
    },
  ));

  return dio;
});

