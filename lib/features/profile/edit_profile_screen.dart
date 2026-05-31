import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop/crop.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/services/api_service.dart';
import 'profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _displayNameCtrl = TextEditingController();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _setNewPasswordCtrl = TextEditingController();
  final _setConfirmPasswordCtrl = TextEditingController();
  final _api = ApiService();

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _settingPassword = false;
  bool _uploadingAvatar = false;
  String? _email;
  String? _avatarUrl;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _api.get('/users/me');
      _displayNameCtrl.text = data['display_name'] ?? '';
      _email = data['email'];
      _avatarUrl = data['avatar_url'];
      _isGoogleUser = data['has_password'] == false;
    } catch (_) {}
    if (mounted) setState(() => _loadingProfile = false);
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    final croppedPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _CropPage(imagePath: picked.path),
        fullscreenDialog: true,
      ),
    );
    if (croppedPath == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final data = await _api.uploadAvatar(croppedPath);
      _avatarUrl = data['avatar_url'];
      ref.invalidate(userProfileProvider);
      if (mounted) {
        final t = ref.read(translationsProvider);
        _snack(t['edit_upload_ok'] ?? 'อัปโหลดรูปโปรไฟล์สำเร็จ', success: true);
      }
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) {
        final t = ref.read(translationsProvider);
        _snack(t['edit_upload_fail'] ?? 'ไม่สามารถอัปโหลดรูปได้');
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    final t = ref.read(translationsProvider);
    final name = _displayNameCtrl.text.trim();
    if (name.isEmpty) {
      _snack(t['edit_name_empty'] ?? 'กรุณากรอกชื่อที่แสดง');
      return;
    }
    setState(() => _savingProfile = true);
    try {
      await _api.patch('/users/me', {'display_name': name});
      ref.invalidate(userProfileProvider);
      if (mounted) _snack(t['edit_save_ok'] ?? 'บันทึกสำเร็จ', success: true);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack(t['server_error'] ?? 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    final t = ref.read(translationsProvider);
    final current = _currentPasswordCtrl.text;
    final newPass = _newPasswordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    if (current.isEmpty || newPass.isEmpty) {
      _snack(t['edit_pw_empty'] ?? 'กรุณากรอกรหัสผ่านให้ครบ');
      return;
    }
    if (newPass != confirm) {
      _snack(t['edit_pw_mismatch'] ?? 'รหัสผ่านใหม่ไม่ตรงกัน');
      return;
    }
    if (newPass.length < 8) {
      _snack(t['edit_pw_short'] ?? 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร');
      return;
    }

    setState(() => _savingPassword = true);
    try {
      await _api.put('/users/me/password', {
        'current_password': current,
        'new_password': newPass,
      });
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      if (mounted) _snack(t['edit_pw_ok'] ?? 'เปลี่ยนรหัสผ่านสำเร็จ', success: true);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack(t['server_error'] ?? 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _setPassword() async {
    final t = ref.read(translationsProvider);
    final newPass = _setNewPasswordCtrl.text;
    final confirm = _setConfirmPasswordCtrl.text;

    if (newPass.isEmpty || confirm.isEmpty) {
      _snack('กรุณากรอกรหัสผ่านให้ครบ');
      return;
    }
    if (newPass.length < 8) {
      _snack(t['edit_pw_short'] ?? 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร');
      return;
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(newPass) || !RegExp(r'\d').hasMatch(newPass)) {
      _snack('รหัสผ่านต้องมีทั้งตัวอักษรและตัวเลข');
      return;
    }
    if (newPass != confirm) {
      _snack(t['edit_pw_mismatch'] ?? 'รหัสผ่านใหม่ไม่ตรงกัน');
      return;
    }

    setState(() => _settingPassword = true);
    try {
      await _api.post('/users/me/set-password', {
        'new_password': newPass,
        'confirm_password': confirm,
      });
      _setNewPasswordCtrl.clear();
      _setConfirmPasswordCtrl.clear();
      setState(() => _isGoogleUser = false);
      if (mounted) _snack('ตั้งรหัสผ่านสำเร็จ สามารถ login ด้วย email+password ได้แล้ว', success: true);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack(t['server_error'] ?? 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    } finally {
      if (mounted) setState(() => _settingPassword = false);
    }
  }

  void _snack(String msg, {bool success = false}) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Noto Serif Thai', color: Colors.white, fontSize: 13),
        ),
        backgroundColor: success ? AppColors.sage : AppColors.mahogany,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _setNewPasswordCtrl.dispose();
    _setConfirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.watch(translationsProvider);
    final lang = ref.watch(languageProvider) ?? 'th';
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          translations['appbar_edit_profile'] ?? 'แก้ไขโปรไฟล์',
          style: TextStyle(
            fontFamily: lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
            fontSize: lang == 'en' ? 14 : 18,
            letterSpacing: lang == 'en' ? 4 : 0.5,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar ────────────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2),
                          ),
                          child: ClipOval(
                            child: _uploadingAvatar
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.gold,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : _avatarUrl != null
                                    ? Image.network(
                                        _avatarUrl!.startsWith('http')
                                            ? _avatarUrl!
                                            : '${kBaseUrl.replaceAll('/api/v1', '')}$_avatarUrl',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _placeholder(),
                                      )
                                    : _placeholder(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: AppColors.ink),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      translations['edit_avatar_tap'] ?? 'กดที่ไอคอนกล้องเพื่อเปลี่ยนรูปโปรไฟล์',
                      style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── ข้อมูลพื้นฐาน ─────────────────────────────
                  _SectionTitle(translations['edit_basic_info'] ?? 'ข้อมูลส่วนตัว'),
                  const SizedBox(height: 16),

                  _Label(translations['label_email'] ?? 'Email'),
                  _ReadOnlyField(text: _email ?? '-'),
                  const SizedBox(height: 14),

                  _Label(translations['edit_name_label'] ?? 'ชื่อที่แสดง'),
                  _InputField(
                    controller: _displayNameCtrl,
                    hint: translations['edit_name_hint'] ?? 'ชื่อ-นามสกุล หรือชื่อเล่น',
                    icon: Icons.person_outline,
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
                      onPressed: _savingProfile ? null : _saveProfile,
                      child: _savingProfile
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espresso),
                            )
                          : Text(
                              translations['edit_save_btn'] ?? 'บันทึกข้อมูล',
                              style: const TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),

                  if (!_isGoogleUser) ...[
                    const SizedBox(height: 36),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    const SizedBox(height: 24),

                    // ── เปลี่ยนรหัสผ่าน ─────────────────────────
                    _SectionTitle(translations['edit_change_pw'] ?? 'เปลี่ยนรหัสผ่าน'),
                    const SizedBox(height: 16),

                    _Label(translations['edit_current_pw'] ?? 'รหัสผ่านปัจจุบัน'),
                    _InputField(
                      controller: _currentPasswordCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 14),

                    _Label(translations['edit_new_pw'] ?? 'รหัสผ่านใหม่'),
                    _InputField(
                      controller: _newPasswordCtrl,
                      hint: translations['edit_new_pw_hint'] ?? 'อย่างน้อย 8 ตัวอักษร',
                      icon: Icons.lock_reset,
                      isPassword: true,
                    ),
                    const SizedBox(height: 14),

                    _Label(translations['edit_confirm_pw'] ?? 'ยืนยันรหัสผ่านใหม่'),
                    _InputField(
                      controller: _confirmPasswordCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_reset,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _savingPassword ? null : _changePassword,
                        child: _savingPassword
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                              )
                            : Text(
                                translations['edit_change_pw'] ?? 'เปลี่ยนรหัสผ่าน',
                                style: const TextStyle(fontFamily: 'Noto Serif Thai', fontSize: 14),
                              ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 36),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    const SizedBox(height: 24),

                    _SectionTitle('ตั้งรหัสผ่าน'),
                    const SizedBox(height: 6),
                    Text(
                      'เพิ่ม email+password ให้บัญชี Google นี้\nจะสามารถ login ได้ทั้ง 2 วิธี',
                      style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const _Label('รหัสผ่านใหม่'),
                    _InputField(
                      controller: _setNewPasswordCtrl,
                      hint: 'อย่างน้อย 8 ตัว มีตัวเลขและตัวอักษร',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 14),

                    const _Label('ยืนยันรหัสผ่าน'),
                    _InputField(
                      controller: _setConfirmPasswordCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_reset,
                      isPassword: true,
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
                        onPressed: _settingPassword ? null : _setPassword,
                        child: _settingPassword
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espresso))
                            : const Text(
                                'ตั้งรหัสผ่าน',
                                style: TextStyle(fontFamily: 'Noto Serif Thai', fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────

Widget _placeholder() => Container(
      color: AppColors.espresso,
      child: const Icon(Icons.person, color: AppColors.gold, size: 40),
    );

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Noto Serif Thai',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Noto Serif Thai',
            fontSize: 11,
            letterSpacing: 3,
            color: AppColors.amber,
          ),
        ),
      );
}

class _ReadOnlyField extends StatelessWidget {
  final String text;
  const _ReadOnlyField({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Noto Serif Thai',
            fontSize: 13.5,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
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
                ),
              ),
            ),
          ],
        ),
      );
}

// ── In-app Crop Page ──────────────────────────────────────────

class _CropPage extends StatefulWidget {
  final String imagePath;
  const _CropPage({required this.imagePath});

  @override
  State<_CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<_CropPage> {
  final _controller = CropController(aspectRatio: 1);
  bool _processing = false;

  Future<void> _confirm() async {
    setState(() => _processing = true);
    try {
      final cropped = await _controller.crop(pixelRatio: 2.0);
      if (cropped == null || !mounted) return;
      final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null || !mounted) return;
      final tmp = File(
        '${Directory.systemTemp.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tmp.writeAsBytes(byteData.buffer.asUint8List());
      if (mounted) Navigator.pop(context, tmp.path);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ครอปรูปโปรไฟล์',
          style: TextStyle(
            fontFamily: 'Noto Serif Thai',
            fontSize: 16,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_processing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _confirm,
              child: const Text(
                'ยืนยัน',
                style: TextStyle(
                  fontFamily: 'Noto Serif Thai',
                  fontSize: 15,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              controller: _controller,
              shape: BoxShape.circle,
              backgroundColor: Colors.black,
              dimColor: const Color(0xCC000000),
              padding: const EdgeInsets.all(32),
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          ),
          Container(
            color: AppColors.espresso,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined, size: 14, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 8),
                Text(
                  'ลากเพื่อปรับตำแหน่ง  •  บีบนิ้วเพื่อซูม',
                  style: TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
