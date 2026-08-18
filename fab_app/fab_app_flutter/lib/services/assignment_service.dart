import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/assignment.dart';

final assignmentServiceProvider = Provider<AssignmentService>((ref) {
  final dio = ref.watch(dioProvider);
  return AssignmentService(dio);
});

class AssignmentService {
  final Dio _dio;

  AssignmentService(this._dio);

  Future<List<Assignment>> getCurrentAssignments() async {
    try {
      final response = await _dio.get('/assignments/current');
      final List<dynamic> data = response.data;
      return data.map((json) => Assignment.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Assignment>> getHistory() async {
    try {
      final response = await _dio.get('/assignments/history');
      final List<dynamic> data = response.data;
      return data.map((json) => Assignment.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Assignment> assignMachine(int workerId, int machineId, String location) async {
    try {
      final response = await _dio.post('/assignments/assign', data: {
        'worker_id': workerId,
        'machine_id': machineId,
        'location': location,
      });
      return Assignment.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Assignment> returnMachine(int assignmentId) async {
    try {
      final response = await _dio.post('/assignments/$assignmentId/return');
      return Assignment.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Assignment> updateLocation(int assignmentId, String location) async {
    try {
      final response = await _dio.patch(
        '/assignments/$assignmentId/location',
        data: {'location': location},
      );
      return Assignment.fromJson(response.data);
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
      if (e.response?.statusCode == 409) {
        return Exception('Conflict: Operation not allowed.');
      }
      return Exception('Network error: Failed to communicate with server. Please try again.');
    }
    return Exception('An unexpected error occurred.');
  }
}
