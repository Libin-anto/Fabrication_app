import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../core/storage/secure_storage.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(authService, secureStorage);
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthService _authService;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._authService, this._secureStorage) : super(const AsyncValue.loading()) {
    _clearSessionOnStartup();
  }

  Future<void> _clearSessionOnStartup() async {
    try {
      // Clear token on start to guarantee cold starts begin at the login screen
      await _secureStorage.deleteToken();
      state = const AsyncValue.data(false);
    } catch (_) {
      state = const AsyncValue.data(false);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.login(username, password);
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      // Immediately reset to unauthenticated after error so UI can show it,
      // but doesn't get stuck in error state forever
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) state = const AsyncValue.data(false);
      });
      rethrow;
    }
  }

  Future<void> register(String username, String password, String adminKey, {String? name}) async {
    state = const AsyncValue.loading();
    try {
      await _authService.register(username, password, adminKey, name: name);
      state = const AsyncValue.data(false); // Stay unauthenticated, let user log in manually after success
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) state = const AsyncValue.data(false);
      });
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authService.logout();
    state = const AsyncValue.data(false);
  }
}
