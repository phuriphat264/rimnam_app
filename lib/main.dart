import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_colors.dart';
import 'core/storage/storage_service.dart';
import 'core/services/api_service.dart';
import 'features/language/language_screen.dart';
import 'features/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('chanthaburi').manage.create();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = await ApiService().isLoggedIn();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: RimnamApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class RimnamApp extends StatelessWidget {
  final bool isLoggedIn;
  const RimnamApp({super.key, required this.isLoggedIn});

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
      
      home: isLoggedIn ? const MainScreen() : const LanguageScreenPremium(),
    );
  }
}