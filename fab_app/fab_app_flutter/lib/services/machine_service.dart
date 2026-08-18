import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/machine.dart';

final machineServiceProvider = Provider<MachineService>((ref) {
  final dio = ref.watch(dioProvider);
  return MachineService(dio);
});

class MachineService {
  final Dio _dio;

  MachineService(this._dio);

  Future<List<Machine>> getMachines() async {
    try {
      final response = await _dio.get('/machines/');
      final List<dynamic> data = response.data;
      return data.map((json) => Machine.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Machine> createMachine(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/machines/', data: data);
      return Machine.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Machine> updateMachine(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/machines/$id', data: data);
      return Machine.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteMachine(int id) async {
    try {
      await _dio.delete('/machines/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 422) {
        return Exception('Validation Error: Invalid data format.');
      }
      // Provide backend error message if available
      final detail = e.response?.data?['detail'];
      if (detail != null && detail is String) {
        return Exception(detail);
      }
      return Exception('Network error: Failed to communicate with server.');
    }
    return Exception('An unexpected error occurred.');
  }
}
