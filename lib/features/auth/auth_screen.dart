import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/widgets/city_illustration.dart';
import 'auth_provider.dart';
import '../history/history_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final translations = ref.watch(translationsProvider);
    final isLogin = authState.mode == AuthMode.login;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.linen,
      body: Column(
        children: [
          // ── Hero Section ──
          Container(
            color: AppColors.ink,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Illustration
                    SizedBox(
                      height: isSmallScreen ? 110.0 : 140.0,
                      child: const CityIllustration(),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      isLogin
                          ? translations['login_title'] ?? ''
                          : translations['register_title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form Section ──
          Expanded(
            child: Container(
              color: AppColors.linen,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      isLogin
                          ? translations['login_title'] ?? ''
                          : translations['register_title'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.espresso,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isLogin
                          ? 'ยินดีต้อนรับกลับ'
                          : 'สร้างบัญชีเพื่อเริ่มการเดินทาง',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.sienna,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _FieldLabel(label: translations['email_hint'] ?? 'อีเมล'),
                    _FormField(
                      hint: translations['email_hint'] ?? '',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),

                    // Password
                    _FieldLabel(label: translations['password_hint'] ?? 'รหัสผ่าน'),
                    _FormField(
                      hint: translations['password_hint'] ?? '',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    // Forgot Password
                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: const Text(
                            'ลืมรหัสผ่าน?',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.caramel,
                            ),
                          ),
                        ),
                      ),

                    // Confirm Password (Register)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: !isLogin
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                _FieldLabel(
                                  label: translations['confirm_password_hint'] ?? 'ยืนยันรหัสผ่าน',
                                ),
                                _FormField(
                                  hint: translations['confirm_password_hint'] ?? '',
                                  icon: Icons.lock_reset,
                                  isPassword: true,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.espresso,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.gold.withOpacity(0.35),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        },
                        child: Text(
                          isLogin
                              ? translations['login_title'] ?? ''
                              : translations['register_title'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),

                    // Divider OR
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.mahogany.withOpacity(0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'หรือ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.caramel.withOpacity(0.45),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.mahogany.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle Mode Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mahogany,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(
                            color: AppColors.mahogany.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => ref.read(authProvider.notifier).toggleMode(),
                        child: Text(
                          isLogin
                              ? translations['no_account'] ?? ''
                              : translations['has_account'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: 3,
          color: AppColors.sienna,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _FormField({
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.mahogany.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.espresso,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.5),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.gold.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}