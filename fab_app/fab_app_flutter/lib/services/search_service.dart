import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

final searchServiceProvider = Provider((ref) {
  return SearchService(ref.read(dioProvider));
});

class SearchService {
  final Dio _dio;

  SearchService(this._dio);

  Future<List<Map<String, dynamic>>> searchGlobal(String query) async {
    try {
      final response = await _dio.get('/search/', queryParameters: {'q': query});
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Search failed');
    }
  }
}
