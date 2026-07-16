import 'package:equatable/equatable.dart';

import 'user.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  const AuthState.initial() : this(isLoading: true);

  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, error, isAuthenticated];
}
