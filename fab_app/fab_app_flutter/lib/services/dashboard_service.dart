import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardService(dio);
});

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired');
      }
      throw Exception('Network error: Failed to fetch dashboard statistics.');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }
}
