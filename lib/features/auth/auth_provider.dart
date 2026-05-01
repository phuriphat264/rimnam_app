import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthMode { login, register }

class AuthState {
  final AuthMode mode;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.mode = AuthMode.login,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthMode? mode,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == AuthMode.login ? AuthMode.register : AuthMode.login,
      clearError: true,
    );
  }

  Future<void> submit({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // Mock Authentication Delay
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement Real Auth Repository here
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}