import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/api_service.dart';

enum AuthMode { login, register }

class AuthState {
  final AuthMode mode;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.mode = AuthMode.login,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AuthMode? mode,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Web client ID — ทำให้ idToken ใน backend verify ได้ถูกต้อง
  serverClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _api = ApiService();

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == AuthMode.login ? AuthMode.register : AuthMode.login,
      clearError: true,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _api.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      }, auth: false);

      await _api.saveTokens(data['access_token'], data['refresh_token']);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String language = 'th',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final username = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

      final data = await _api.post('/auth/register', {
        'email': email.trim(),
        'password': password,
        'username': username,
        'display_name': displayName.trim().isEmpty ? username : displayName.trim(),
        'language': language,
      }, auth: false);

      await _api.saveTokens(data['access_token'], data['refresh_token']);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Sign out ก่อนทุกครั้งเพื่อ force account picker ขึ้นมาเสมอ
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'ไม่สามารถดึง Google token ได้');
        return;
      }

      final data = await _api.post('/auth/google', {'id_token': idToken}, auth: false);
      await _api.saveTokens(data['access_token'], data['refresh_token']);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Google Sign-In ล้มเหลว');
    }
  }

  // คืนค่า null ถ้าสำเร็จ, คืน error message ถ้าล้มเหลว
  Future<String?> sendForgotPasswordOtp(String email) async {
    try {
      await _api.post('/auth/forgot-password', {'email': email.trim()}, auth: false);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }
  }

  // คืนค่า null ถ้าสำเร็จ, คืน error message ถ้าล้มเหลว
  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _api.post('/auth/reset-password', {
        'email': email.trim(),
        'otp': otp.trim(),
        'new_password': newPassword,
      }, auth: false);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }
  }

  Future<void> logout() async {
    final refresh = await _api.getRefreshToken();
    if (refresh != null) {
      try {
        await _api.post('/auth/logout', {'refresh_token': refresh});
      } catch (_) {}
    }
    await _api.clearTokens();
    await _googleSignIn.signOut();
    state = const AuthState();
  }
}
