import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import 'auth_provider.dart';
import '../main/main_screen.dart';
import '../history/history_screen.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _displayNameCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthState authState) async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    final isLogin = authState.mode == AuthMode.login;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('กรุณากรอก Email และรหัสผ่าน');
      return;
    }

    if (!isLogin) {
      if (password.length < 8) {
        _showSnackBar('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร');
        return;
      }
      if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
        _showSnackBar('รหัสผ่านต้องมีตัวอักษรภาษาอังกฤษอย่างน้อย 1 ตัว');
        return;
      }
      if (!RegExp(r'\d').hasMatch(password)) {
        _showSnackBar('รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว');
        return;
      }
      if (password != _confirmPasswordCtrl.text) {
        _showSnackBar('รหัสผ่านไม่ตรงกัน');
        return;
      }
      await ref.read(authProvider.notifier).register(
            email: email,
            password: password,
            displayName: _displayNameCtrl.text,
            language: ref.read(languageProvider) ?? 'th',
          );
    } else {
      await ref.read(authProvider.notifier).login(
            email: email,
            password: password,
          );
    }

    if (!mounted) return;
    final newState = ref.read(authProvider);
    if (newState.isAuthenticated) {
      await ref.read(placesProvider.notifier).resetAndSyncFromServer();
      if (mounted) _navigateAfterLogin();
    }
  }

  Future<void> _googleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final newState = ref.read(authProvider);
    if (newState.isAuthenticated) {
      await ref.read(placesProvider.notifier).resetAndSyncFromServer();
      if (mounted) _navigateAfterLogin();
    }
  }

  void _navigateAfterLogin() {
    final places = ref.read(placesProvider);
    final isAllDone = places.every((p) => p.status == PlaceStatus.done);

    // ล้าง stack เก่าทั้งหมด → MainScreen เป็น root
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );

    // ถ้าทำครบทุกภารกิจ → เปิดสมุดประทับไว้บน MainScreen
    if (isAllDone) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
    }
  }

  void _openForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPasswordSheet(
        onSuccess: () {
          Navigator.pop(context);
          _showSnackBar('เปลี่ยนรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบใหม่');
        },
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'Noto Serif Thai',
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor: AppColors.mahogany,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final translations = ref.watch(translationsProvider);
    final isLogin = authState.mode == AuthMode.login;
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    ref.listen(authProvider, (_, next) {
      if (next.errorMessage != null && mounted) {
        _showSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Column(
        children: [
          // ── Header (photo hero) ───────────────────────────────
          SizedBox(
            height: isSmallScreen ? 165.0 : 210.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/7.jpg',
                  fit: BoxFit.cover,
                ),
                // gradient: ทึบบนสุด (status bar) → โปร่งกลาง → ทึบล่าง (text)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xCC1C1208),
                        Colors.transparent,
                        Color(0xF21C1208),
                      ],
                      stops: [0.0, 0.38, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isLogin
                              ? translations['login_title'] ?? 'เข้าสู่ระบบ'
                              : translations['register_title'] ?? 'สมัครสมาชิก',
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cream,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isLogin
                              ? translations['login_subtitle'] ?? 'ยินดีต้อนรับกลับ'
                              : translations['register_subtitle'] ?? 'สร้างบัญชีเพื่อเริ่มการเดินทาง',
                          style: TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 12,
                            color: AppColors.amber.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Form ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อที่แสดง (เฉพาะ register)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: !isLogin
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(label: 'ชื่อที่แสดง'),
                              _FormField(
                                hint: 'ชื่อ-นามสกุล หรือชื่อเล่น',
                                icon: Icons.person_outline,
                                controller: _displayNameCtrl,
                              ),
                              const SizedBox(height: 14),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  _FieldLabel(label: translations['email_hint'] ?? 'อีเมล'),
                  _FormField(
                    hint: translations['email_hint'] ?? 'อีเมล',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [_LowercaseFormatter()],
                  ),
                  const SizedBox(height: 14),

                  _FieldLabel(label: translations['password_hint'] ?? 'รหัสผ่าน'),
                  _FormField(
                    hint: translations['password_hint'] ?? 'รหัสผ่าน',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordCtrl,
                  ),

                  if (!isLogin)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 2),
                      child: Text(
                        'อย่างน้อย 8 ตัวอักษร มีตัวเลขและตัวอักษรภาษาอังกฤษ',
                        style: TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 10,
                          color: AppColors.caramel.withOpacity(0.6),
                        ),
                      ),
                    ),

                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _openForgotPassword,
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
                        child: Text(
                          translations['forgot_password'] ?? 'ลืมรหัสผ่าน?',
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 11,
                            color: AppColors.caramel,
                          ),
                        ),
                      ),
                    ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: !isLogin
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 14),
                              _FieldLabel(label: translations['confirm_password_hint'] ?? 'ยืนยันรหัสผ่าน'),
                              _FormField(
                                hint: translations['confirm_password_hint'] ?? 'ยืนยันรหัสผ่าน',
                                icon: Icons.lock_reset,
                                isPassword: true,
                                controller: _confirmPasswordCtrl,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // ── Login / Register button ───────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.espresso,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        shadowColor: AppColors.gold.withOpacity(0.4),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return AppColors.espresso.withOpacity(0.15);
                          }
                          return null;
                        }),
                      ),
                      onPressed: authState.isLoading ? null : () => _submit(authState),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espresso),
                            )
                          : Text(
                              isLogin
                                  ? translations['login_title'] ?? 'เข้าสู่ระบบ'
                                  : translations['register_title'] ?? 'สมัครสมาชิก',
                              style: const TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                              ),
                            ),
                    ),
                  ),

                  // ── Divider ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            translations['or_divider'] ?? 'หรือ',
                            style: TextStyle(
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 11,
                              color: AppColors.caramel.withOpacity(0.5),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                      ],
                    ),
                  ),

                  // ── Google Sign-In button ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        foregroundColor: AppColors.cream,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white.withOpacity(0.05);
                          }
                          return null;
                        }),
                      ),
                      onPressed: authState.isLoading ? null : _googleSignIn,
                      icon: _GoogleLogo(),
                      label: Text(
                        isLogin ? 'เข้าสู่ระบบด้วย Google' : 'สมัครด้วย Google',
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 13,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Toggle mode button ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return AppColors.gold.withOpacity(0.08);
                          }
                          return null;
                        }),
                      ),
                      onPressed: () => ref.read(authProvider.notifier).toggleMode(),
                      child: Text(
                        isLogin
                            ? translations['no_account'] ?? 'ยังไม่มีบัญชี? สมัครสมาชิก'
                            : translations['has_account'] ?? 'มีบัญชีแล้ว? เข้าสู่ระบบ',
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Google logo widget ────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/google_logo.png',
      width: 22,
      height: 22,
    );
  }
}

// ── Forgot Password Bottom Sheet ──────────────────────────────
class _ForgotPasswordSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const _ForgotPasswordSheet({required this.onSuccess});

  @override
  ConsumerState<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<_ForgotPasswordSheet> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _setError(String msg) => setState(() => _errorMsg = msg);
  void _clearError() => setState(() => _errorMsg = null);

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) {
      _setError('กรุณากรอก Email');
      return;
    }
    _clearError();
    setState(() => _isLoading = true);
    final err = await ref.read(authProvider.notifier).sendForgotPasswordOtp(email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (err != null) {
      _setError(err);
    } else {
      setState(() => _otpSent = true);
    }
  }

  Future<void> _resetPassword() async {
    final newPass = _newPassCtrl.text;
    final otp = _otpCtrl.text.trim();

    if (otp.length != 6) { _setError('กรุณากรอก OTP 6 หลัก'); return; }
    if (newPass.length < 8) { _setError('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'); return; }
    if (!RegExp(r'[A-Za-z]').hasMatch(newPass) || !RegExp(r'\d').hasMatch(newPass)) {
      _setError('รหัสผ่านต้องมีทั้งตัวอักษรและตัวเลข'); return;
    }
    if (newPass != _confirmPassCtrl.text) { _setError('รหัสผ่านไม่ตรงกัน'); return; }

    _clearError();
    setState(() => _isLoading = true);
    final err = await ref.read(authProvider.notifier).resetPassword(
          email: _emailCtrl.text.trim().toLowerCase(),
          otp: otp,
          newPassword: newPass,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (err != null) {
      _setError(err);
    } else {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.espresso,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mahogany,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'ลืมรหัสผ่าน',
              style: const TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _otpSent
                  ? 'กรอก OTP ที่ส่งไปยัง ${_emailCtrl.text}'
                  : 'กรอก Email ที่ใช้ลงทะเบียน',
              style: TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 12,
                color: AppColors.amber.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // ── Inline error banner ──────────────────────────
            if (_errorMsg != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 13,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!_otpSent) ...[
              const _FieldLabel(label: 'EMAIL'),
              _FormField(
                hint: 'your@email.com',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [_LowercaseFormatter()],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.espresso,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espresso))
                      : const Text('ส่ง OTP ไปยัง Email', style: TextStyle(fontFamily: 'Noto Serif Thai', fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              // ── Success banner ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.mark_email_read_outlined, color: Colors.green, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ส่ง OTP ไปยัง',
                            style: TextStyle(
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 12,
                              color: Colors.green.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            _emailCtrl.text,
                            style: const TextStyle(
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'กรุณาตรวจสอบ inbox (รวมถึง spam)',
                            style: TextStyle(
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 11,
                              color: Colors.green.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _FieldLabel(label: 'OTP 6 หลัก'),
              _FormField(
                hint: '000000',
                icon: Icons.pin_outlined,
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              const _FieldLabel(label: 'รหัสผ่านใหม่'),
              _FormField(
                hint: 'อย่างน้อย 8 ตัว มีตัวเลขและตัวอักษร',
                icon: Icons.lock_outline,
                controller: _newPassCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 14),
              const _FieldLabel(label: 'ยืนยันรหัสผ่านใหม่'),
              _FormField(
                hint: 'ยืนยันรหัสผ่าน',
                icon: Icons.lock_reset,
                controller: _confirmPassCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => setState(() { _otpSent = false; _clearError(); }),
                    child: const Text('ส่งใหม่', style: TextStyle(fontFamily: 'Noto Serif Thai', color: AppColors.caramel, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.espresso,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _resetPassword,
                      child: _isLoading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espresso))
                          : const Text('เปลี่ยนรหัสผ่าน', style: TextStyle(fontFamily: 'Noto Serif Thai', fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Reusable field label ───────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Noto Serif Thai',
          fontSize: 11,
          letterSpacing: 3,
          color: AppColors.amber,
        ),
      ),
    );
  }
}

// ── Reusable input field (dark glass style) ───────────────────
class _FormField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Icon(icon, color: AppColors.gold.withOpacity(0.65), size: 18),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 13.5,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Noto Serif Thai',
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13.5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                isDense: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LowercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
