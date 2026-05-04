class AppTranslations {
  AppTranslations._();

  static const Map<String, Map<String, String>> strings = {
    'th': {
      'app_name': 'ริมน้ำจันทบูร',
      'app_subtitle': 'Chanthabun Riverside',
      'continue_btn': 'ดำเนินการต่อ',
      'login_title': 'เข้าสู่ระบบ',
      'register_title': 'สร้างบัญชีใหม่',
      'email_hint': 'อีเมล',
      'password_hint': 'รหัสผ่าน',
      'confirm_password_hint': 'ยืนยันรหัสผ่าน',
      'no_account': 'ยังไม่มีบัญชี? สมัครใช้งาน',
      'has_account': 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
      'welcome': 'ยินดีต้อนรับสู่',
      'home_desc': 'ออกเดินทางสัมผัสวิถีชีวิตและสถาปัตยกรรมที่งดงามผ่านภารกิจ 6 จุดสำคัญ',
      'start_journey': 'เริ่มต้นการเดินทาง',
      'nav_home': 'หน้าแรก',
      'nav_map': 'แผนที่',
      'nav_mission': 'ภารกิจ',
      'nav_profile': 'โปรไฟล์',
    },
    'zh': {
      'app_name': '尖竹汶河畔',
      'app_subtitle': 'Chanthabun Riverside',
      'continue_btn': '继续',
      'login_title': '登录',
      'register_title': '创建账户',
      'email_hint': '电子邮件',
      'password_hint': '密码',
      'confirm_password_hint': '确认密码',
      'no_account': '没有账户？注册',
      'has_account': '已有账户？登录',
      'welcome': '欢迎来到',
      'home_desc': '通过6个关键任务，踏上体验美丽生活方式和建筑的旅程',
      'start_journey': '开始旅程',
      'nav_home': '首页',
      'nav_map': '地图',
      'nav_mission': '任务',
      'nav_profile': '个人资料',
    },
    'en': {
      'app_name': 'Chanthabun',
      'app_subtitle': 'Riverside Experience',
      'continue_btn': 'Continue',
      'login_title': 'Login',
      'register_title': 'Create Account',
      'email_hint': 'Email',
      'password_hint': 'Password',
      'confirm_password_hint': 'Confirm Password',
      'no_account': 'No account? Register',
      'has_account': 'Already have an account? Login',
      'welcome': 'Welcome to',
      'home_desc': 'Embark on a journey to experience the beautiful lifestyle and architecture through 6 key missions.',
      'start_journey': 'Start Journey',
      'nav_home': 'Home',
      'nav_map': 'Map',
      'nav_mission': 'Missions',
      'nav_profile': 'Profile',
    },
  };

  static String get(String languageCode, String key) {
    return strings[languageCode]?[key] ?? key;
  }

  static Map<String, String>? getLanguage(String languageCode) {
    return strings[languageCode];
  }

  static bool isLanguageSupported(String languageCode) {
    return strings.containsKey(languageCode);
  }

  static List<String> getSupportedLanguages() {
    return strings.keys.toList();
  }
}