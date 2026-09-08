import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/admin.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(dio, secureStorage);
});

class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthService(this._dio, this._storage);

  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      final token = response.data['access_token'];
      if (token != null) {
        await _storage.saveToken(token);
        await _storage.savePassword(password);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Validation Error: Please check your input format.');
      }
      throw Exception('Network error: Unable to connect to server.');
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<void> register(String username, String password, {String? name}) async {
    try {
      await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        'name': name,
      });
      // Optionally login automatically after register, but based on RN we just return success
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Registration failed.');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Validation Error: Please check your input format.');
      }
      throw Exception('Network error: Unable to connect to server.');
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    await _storage.deletePassword();
  }

  Future<Admin> getMyProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return Admin.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout(); // Token expired or invalid
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception('Failed to fetch profile.');
    }
  }

  Future<Admin> updateMyProfile(String name, String role) async {
    try {
      final response = await _dio.put('/auth/me', data: {
        'name': name,
        'role': role,
      });
      return Admin.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation Error: Please check your input format.');
      }
      throw Exception(e.response?.data?['detail'] ?? 'Failed to update profile.');
    } catch (e) {
      throw Exception('An unexpected error occurred while updating profile.');
    }
  }
}
