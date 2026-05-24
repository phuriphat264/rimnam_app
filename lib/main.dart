import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_colors.dart';
import 'core/storage/storage_service.dart';
import 'features/language/language_screen.dart';

void main() async {
  // จำเป็นต้องเรียกใช้เมื่อมีการใช้ async ก่อน runApp (เช่น การโหลด SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // โหลด SharedPreferences เตรียมไว้ตั้งแต่เริ่มแอป
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // นำ prefs ที่โหลดเสร็จแล้ว มาใส่ใน Provider เพื่อให้ทั้งแอปดึงไปใช้งานได้ทันที (Synchronous)
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const RimnamApp(),
    ),
  );
}

class RimnamApp extends StatelessWidget {
  const RimnamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ริมน้ำจันทบูร (Rimnam Chanthabun)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.ink,
        primaryColor: AppColors.gold,
        
        // ==========================================
        // การตั้งค่า Google Fonts ที่ดึงโทนสีของแอปมาใช้
        // ==========================================
        textTheme: GoogleFonts.notoSerifThaiTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppColors.cream,     // สีหลักสำหรับข้อความทั่วไป (เนื้อหา)
            displayColor: AppColors.gold,   // สีหลักสำหรับข้อความหัวข้อ (Header/Title)
          ),
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.dark, // คุมโทนแอปให้เป็น Dark Mode เสมอ
          primary: AppColors.gold,
          secondary: AppColors.amber,
          surface: AppColors.ink,
        ),
        
        useMaterial3: true,
      ),
      
      // เริ่มต้น Flow ด้วยหน้าเลือกภาษา
      home: const LanguageScreenPremium(),
    );
  }
}