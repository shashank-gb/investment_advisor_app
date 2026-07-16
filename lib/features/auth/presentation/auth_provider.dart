import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    _checkSession();
  }

  final AuthRepository _repository;

  Future<void> _checkSession() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AuthState(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('ApiException(', '').replaceAll(')', ''),
      );
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(isLoading: false);
  }
}
