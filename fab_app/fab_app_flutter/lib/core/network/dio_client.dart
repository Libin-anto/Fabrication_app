import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final dio = Dio();

  // Load Base URL from compile-time environment, default to Android emulator localhost
  const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');
  
  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Add Auth Interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await secureStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException error, handler) {
      // We can handle global 401s or 422s here if needed
      return handler.next(error);
    },
  ));

  return dio;
});
