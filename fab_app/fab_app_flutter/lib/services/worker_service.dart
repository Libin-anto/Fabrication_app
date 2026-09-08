import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/worker.dart';

final workerServiceProvider = Provider<WorkerService>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkerService(dio);
});

class WorkerService {
  final Dio _dio;

  WorkerService(this._dio);

  Future<List<Worker>> getWorkers() async {
    try {
      final response = await _dio.get('/workers/');
      final List<dynamic> data = response.data;
      return data.map((json) => Worker.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Worker> createWorker(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/workers/', data: data);
      return Worker.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Worker> updateWorker(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/workers/$id', data: data);
      return Worker.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteWorker(int id) async {
    try {
      await _dio.delete('/workers/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 422) {
        return Exception('Validation Error: Invalid data format.');
      }
      final detail = e.response?.data?['detail'];
      if (detail != null && detail is String) {
        return Exception(detail);
      }
      return Exception('Network error: Failed to communicate with server.');
    }
    return Exception('An unexpected error occurred.');
  }
}
