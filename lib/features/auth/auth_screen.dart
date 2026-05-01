import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import 'auth_provider.dart';
import '../history/history_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final translations = ref.watch(translationsProvider);
    final isLogin = authState.mode == AuthMode.login;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Blurred)
          Image.network(
            'https://images.unsplash.com/photo-1590059345717-3d122f518e3c?q=80&w=1000',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLogin
                                    ? translations['login_title'] ?? ''
                                    : translations['register_title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),

                              _GlassTextField(
                                hint: translations['email_hint'] ?? '',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 16),
                              _GlassTextField(
                                hint: translations['password_hint'] ?? '',
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),

                              // Smooth Reveal Confirm Password
                              AnimatedSize(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                child: !isLogin
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: _GlassTextField(
                                          hint: translations['confirm_password_hint'] ?? '',
                                          icon: Icons.lock_reset,
                                          isPassword: true,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 32),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: AppColors.ink,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HistoryScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    isLogin
                                        ? translations['login_title'] ?? ''
                                        : translations['register_title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Toggle Mode Button
                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).toggleMode();
                      },
                      child: Text(
                        isLogin
                            ? translations['no_account'] ?? ''
                            : translations['has_account'] ?? '',
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
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

// Widget สำหรับช่องกรอกข้อมูลแบบ Glass
class _GlassTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _GlassTextField({
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: AppColors.gold.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}