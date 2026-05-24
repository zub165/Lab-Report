import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  spanish,
  french,
  arabic,
  urdu,
  hindi,
  german,
  portuguese,
  chinese,
  turkish,
  bengali,
}

class LanguageOption {
  final AppLanguage language;
  final String nativeTitle;
  final String englishTitle;
  final String flag;

  const LanguageOption({
    required this.language,
    required this.nativeTitle,
    required this.englishTitle,
    required this.flag,
  });
}

/// App-wide strings for bottom nav, drawer tabs, and settings.
class LanguageProvider extends ChangeNotifier {
  static const _prefsKey = 'app_language_code';

  AppLanguage _currentLanguage = AppLanguage.english;
  bool _loaded = false;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isLoaded => _loaded;

  Locale get locale {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.spanish:
        return const Locale('es');
      case AppLanguage.french:
        return const Locale('fr');
      case AppLanguage.arabic:
        return const Locale('ar');
      case AppLanguage.urdu:
        return const Locale('ur');
      case AppLanguage.hindi:
        return const Locale('hi');
      case AppLanguage.german:
        return const Locale('de');
      case AppLanguage.portuguese:
        return const Locale('pt');
      case AppLanguage.chinese:
        return const Locale('zh');
      case AppLanguage.turkish:
        return const Locale('tr');
      case AppLanguage.bengali:
        return const Locale('bn');
    }
  }

  TextDirection get textDirection =>
      _currentLanguage == AppLanguage.arabic ||
              _currentLanguage == AppLanguage.urdu
          ? TextDirection.rtl
          : TextDirection.ltr;

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(language: AppLanguage.english, nativeTitle: 'English', englishTitle: 'English', flag: '🇺🇸'),
    LanguageOption(language: AppLanguage.spanish, nativeTitle: 'Español', englishTitle: 'Spanish', flag: '🇪🇸'),
    LanguageOption(language: AppLanguage.french, nativeTitle: 'Français', englishTitle: 'French', flag: '🇫🇷'),
    LanguageOption(language: AppLanguage.arabic, nativeTitle: 'العربية', englishTitle: 'Arabic', flag: '🇸🇦'),
    LanguageOption(language: AppLanguage.urdu, nativeTitle: 'اردو', englishTitle: 'Urdu', flag: '🇵🇰'),
    LanguageOption(language: AppLanguage.hindi, nativeTitle: 'हिन्दी', englishTitle: 'Hindi', flag: '🇮🇳'),
    LanguageOption(language: AppLanguage.german, nativeTitle: 'Deutsch', englishTitle: 'German', flag: '🇩🇪'),
    LanguageOption(language: AppLanguage.portuguese, nativeTitle: 'Português', englishTitle: 'Portuguese', flag: '🇧🇷'),
    LanguageOption(language: AppLanguage.chinese, nativeTitle: '中文', englishTitle: 'Chinese', flag: '🇨🇳'),
    LanguageOption(language: AppLanguage.turkish, nativeTitle: 'Türkçe', englishTitle: 'Turkish', flag: '🇹🇷'),
    LanguageOption(language: AppLanguage.bengali, nativeTitle: 'বাংলা', englishTitle: 'Bengali', flag: '🇧🇩'),
  ];

  LanguageProvider() {
    loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      _currentLanguage = _fromCode(code);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _toCode(language));
    notifyListeners();
  }

  String getText(String key) {
    return _all[_currentLanguage]?[key] ??
        _all[AppLanguage.english]![key] ??
        key;
  }

  static String _toCode(AppLanguage l) {
    switch (l) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.urdu:
        return 'ur';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.portuguese:
        return 'pt';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.turkish:
        return 'tr';
      case AppLanguage.bengali:
        return 'bn';
    }
  }

  static AppLanguage _fromCode(String code) {
    switch (code) {
      case 'es':
        return AppLanguage.spanish;
      case 'fr':
        return AppLanguage.french;
      case 'ar':
        return AppLanguage.arabic;
      case 'ur':
        return AppLanguage.urdu;
      case 'hi':
        return AppLanguage.hindi;
      case 'de':
        return AppLanguage.german;
      case 'pt':
        return AppLanguage.portuguese;
      case 'zh':
        return AppLanguage.chinese;
      case 'tr':
        return AppLanguage.turkish;
      case 'bn':
        return AppLanguage.bengali;
      default:
        return AppLanguage.english;
    }
  }

  static final Map<String, String> _en = {
    'menu': 'Menu',
    'home': 'Home',
    'more': 'More',
    'more_modules': 'More modules',
    'lab_management': 'Lab Management',
    'log_out': 'Log out',
    'lab_tests': 'Lab Tests',
    'appointments': 'Appointments',
    'payments': 'Payments',
    'archive': 'Archive',
    'images': 'Images',
    'staff': 'Staff',
    'section_laboratory': 'Laboratory',
    'section_system': 'System',
    'section_account': 'Account',
    'manage_lab_details': 'Manage lab details and settings',
    'manage_users': 'Manage system users',
    'schedule_new_appointments': 'Schedule new appointments',
    'generate_new_reports': 'Generate new reports',
    'analytics_charts': 'Analytics & charts',
    'analytics_subtitle': 'Visual trends for patients, tests, and revenue',
    'test_backend': 'Test backend connectivity',
    'manage_local_db': 'Manage local database',
    'theme_selection': 'Theme Selection',
    'choose_theme': 'Choose app theme',
    'language_selection': 'Language Selection',
    'choose_language': 'Choose app language',
    'language_changed': 'Language changed to',
    'privacy_policy': 'Privacy Policy',
    'privacy_subtitle': 'View our privacy practices',
    'terms_of_service': 'Terms of Service',
    'terms_subtitle': 'Read the terms of using the app',
    'profile_subtitle': 'View and edit profile',
    'delete_account_subtitle': 'Permanently delete your account and data',
    'request_deletion': 'Request Account Deletion',
    'request_deletion_subtitle': 'Submit a deletion request to the lab',
    'export_my_data': 'Export My Data',
    'export_subtitle': 'Download CSV (patients, tests, appointments, payments)',
    'logout_subtitle': 'Sign out of the application',
    'refresh_dashboard': 'Refresh dashboard',
    'no_appointments': 'No appointments',
    'no_appointments_hint': 'Schedule one with the + button (SaeedLab /appointments/).',
    'could_not_load_appointments': 'Could not load appointments',
    'no_payments': 'No payments',
    'no_payments_hint': 'Tap + or the card icon to process Cash, Credit/Debit (Stripe), Insurance, or Online — same as SaeedLab Payments.',
    'could_not_load_payments': 'Could not load payments',
    'staff_directory': 'Staff directory',
    'staff_hint': 'Add doctors and lab technicians (admin).',
    'appts_short': 'Appts',
    'dashboard': 'Dashboard',
    'patients': 'Patients',
    'tests': 'Tests',
    'reports': 'Reports',
    'settings': 'Settings',
    'add_patient': 'Add Patient',
    'add_test': 'Add Test',
    'schedule_appointment': 'Schedule Appointment',
    'generate_report': 'Generate Report',
    'laboratory_information': 'Laboratory Information',
    'user_management': 'User Management',
    'api_connection': 'API Connection',
    'database_management': 'Database Management',
    'profile': 'Profile',
    'delete_account': 'Delete Account',
    'logout': 'Logout',
    'save': 'Save',
    'cancel': 'Cancel',
    'edit': 'Edit',
    'delete': 'Delete',
    'view_details': 'View Details',
    'order_test': 'Order Test',
    'edit_test': 'Edit Test',
    'edit_report': 'Edit Report',
    'print_report': 'Print Report',
    'retry': 'Retry',
    'refresh': 'Refresh',
    'name': 'Name',
    'phone': 'Phone',
    'email': 'Email',
    'address': 'Address',
    'gender': 'Gender',
    'date_of_birth': 'Date of Birth',
    'blood_type': 'Blood Type',
    'emergency_contact': 'Emergency Contact',
    'insurance_info': 'Insurance Info',
    'test_name': 'Test Name',
    'test_type': 'Test Type',
    'status': 'Status',
    'priority': 'Priority',
    'price': 'Price',
    'ordered_date': 'Ordered Date',
    'completed_date': 'Completed Date',
    'ordered_by': 'Ordered By',
    'notes': 'Notes',
    'report_title': 'Report Title',
    'report_content': 'Report Content',
    'report_type': 'Report Type',
    'report_date': 'Report Date',
    'authorized_by': 'Authorized By',
    'full_name': 'Full Name',
    'position': 'Position',
    'role': 'Role',
    'department': 'Department',
    'employee_id': 'Employee ID',
    'laboratory_name': 'Laboratory Name',
    'director_name': 'Director Name',
    'license_number': 'License Number',
    'connected': 'Connected',
    'disconnected': 'Disconnected',
    'last_sync': 'Last Sync',
    'pending_sync': 'Pending Sync',
    'total_records': 'Total Records',
    'back_to_backend': 'Back to Backend',
    'local_database_only': 'Local Database Only',
    'force_sync': 'Force Sync All Data',
    'test_connection': 'Test Backend Connection',
    'refresh_status': 'Refresh Status',
    'select_table': 'Select Table',
    'edit_record': 'Edit Record',
    'delete_record': 'Delete Record',
    'no_records': 'No records found',
    'please_select_record': 'Please select a record to edit',
    'record_deleted': 'Record deleted successfully',
    'error_deleting': 'Error deleting record',
    'profile_updated': 'Profile updated successfully',
    'error_saving_profile': 'Error saving profile',
    'account_type': 'Account Type',
    'last_login': 'Last Login',
    'account_created': 'Account Created',
    'active': 'Active',
    'inactive': 'Inactive',
    'pending': 'Pending',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'in_progress': 'In Progress',
    'low': 'Low',
    'normal': 'Normal',
    'high': 'High',
    'urgent': 'Urgent',
    'general': 'General',
    'hematology': 'Hematology',
    'pathology': 'Pathology',
    'microbiology': 'Microbiology',
    'biochemistry': 'Biochemistry',
    'immunology': 'Immunology',
    'administration': 'Administration',
    'administrator': 'Administrator',
    'doctor': 'Doctor',
    'lab_technician': 'Lab Technician',
    'receptionist': 'Receptionist',
    'manager': 'Manager',
  };

  static final Map<AppLanguage, Map<String, String>> _all = {
    AppLanguage.english: _en,
    AppLanguage.spanish: {
      ..._en,
      'menu': 'Menú', 'home': 'Inicio', 'more': 'Más', 'more_modules': 'Más módulos',
      'lab_management': 'Gestión de laboratorio', 'log_out': 'Cerrar sesión',
      'lab_tests': 'Pruebas de lab', 'appointments': 'Citas', 'payments': 'Pagos',
      'archive': 'Archivo', 'images': 'Imágenes', 'staff': 'Personal',
      'section_laboratory': 'Laboratorio', 'section_system': 'Sistema', 'section_account': 'Cuenta',
      'dashboard': 'Panel de Control', 'patients': 'Pacientes', 'tests': 'Pruebas',
      'reports': 'Informes', 'settings': 'Configuración',
      'language_selection': 'Idioma', 'choose_language': 'Elegir idioma',
      'privacy_policy': 'Política de privacidad', 'terms_of_service': 'Términos de servicio',
      'logout': 'Cerrar Sesión', 'profile': 'Perfil', 'retry': 'Reintentar',
    },
    AppLanguage.french: {
      ..._en,
      'menu': 'Menu', 'home': 'Accueil', 'more': 'Plus', 'more_modules': 'Plus de modules',
      'lab_management': 'Gestion du laboratoire', 'log_out': 'Déconnexion',
      'lab_tests': 'Tests labo', 'appointments': 'Rendez-vous', 'payments': 'Paiements',
      'archive': 'Archives', 'images': 'Images', 'staff': 'Personnel',
      'section_laboratory': 'Laboratoire', 'section_system': 'Système', 'section_account': 'Compte',
      'dashboard': 'Tableau de Bord', 'patients': 'Patients', 'tests': 'Tests',
      'reports': 'Rapports', 'settings': 'Paramètres',
      'language_selection': 'Langue', 'choose_language': 'Choisir la langue',
      'privacy_policy': 'Politique de confidentialité', 'terms_of_service': 'Conditions d\'utilisation',
      'logout': 'Déconnexion', 'profile': 'Profil', 'retry': 'Réessayer',
    },
    AppLanguage.arabic: {
      ..._en,
      'menu': 'القائمة', 'home': 'الرئيسية', 'more': 'المزيد', 'more_modules': 'وحدات إضافية',
      'lab_management': 'إدارة المختبر', 'log_out': 'تسجيل الخروج',
      'lab_tests': 'فحوصات المختبر', 'appointments': 'المواعيد', 'payments': 'المدفوعات',
      'archive': 'الأرشيف', 'images': 'الصور', 'staff': 'الموظفون',
      'section_laboratory': 'المختبر', 'section_system': 'النظام', 'section_account': 'الحساب',
      'dashboard': 'لوحة التحكم', 'patients': 'المرضى', 'tests': 'الفحوصات',
      'reports': 'التقارير', 'settings': 'الإعدادات',
      'language_selection': 'اللغة', 'choose_language': 'اختر اللغة',
      'privacy_policy': 'سياسة الخصوصية', 'terms_of_service': 'شروط الخدمة',
      'logout': 'تسجيل الخروج', 'profile': 'الملف الشخصي', 'retry': 'إعادة المحاولة',
    },
    AppLanguage.urdu: {
      ..._en,
      'menu': 'مینو', 'home': 'ہوم', 'more': 'مزید', 'more_modules': 'مزید ماڈیول',
      'lab_management': 'لیب مینجمنٹ', 'log_out': 'لاگ آؤٹ',
      'lab_tests': 'لیب ٹیسٹ', 'appointments': 'اپائنٹمنٹس', 'payments': 'ادائیگیاں',
      'archive': 'آرکائیو', 'images': 'تصاویر', 'staff': 'عملہ',
      'section_laboratory': 'لیبارٹری', 'section_system': 'سسٹم', 'section_account': 'اکاؤنٹ',
      'dashboard': 'ڈیش بورڈ', 'patients': 'مریض', 'tests': 'ٹیسٹ',
      'reports': 'رپورٹس', 'settings': 'سیٹنگز',
      'language_selection': 'زبان', 'choose_language': 'زبان منتخب کریں',
      'privacy_policy': 'رازداری کی پالیسی', 'terms_of_service': 'سروس کی شرائط',
      'logout': 'لاگ آؤٹ', 'profile': 'پروفائل', 'retry': 'دوبارہ کوشش',
    },
    AppLanguage.hindi: {
      ..._en,
      'menu': 'मेनू', 'home': 'होम', 'more': 'और', 'more_modules': 'अधिक मॉड्यूल',
      'lab_management': 'प्रयोगशाला प्रबंधन', 'log_out': 'लॉग आउट',
      'lab_tests': 'लैब परीक्षण', 'appointments': 'अपॉइंटमेंट', 'payments': 'भुगतान',
      'archive': 'संग्रह', 'images': 'चित्र', 'staff': 'कर्मचारी',
      'dashboard': 'डैशबोर्ड', 'patients': 'मरीज़', 'tests': 'परीक्षण',
      'reports': 'रिपोर्ट', 'settings': 'सेटिंग्स',
      'language_selection': 'भाषा', 'choose_language': 'भाषा चुनें',
      'privacy_policy': 'गोपनीयता नीति', 'terms_of_service': 'सेवा की शर्तें',
      'logout': 'लॉग आउट', 'profile': 'प्रोफ़ाइल', 'retry': 'पुनः प्रयास',
    },
    AppLanguage.german: {
      ..._en,
      'menu': 'Menü', 'home': 'Start', 'more': 'Mehr', 'more_modules': 'Weitere Module',
      'lab_management': 'Labormanagement', 'log_out': 'Abmelden',
      'lab_tests': 'Labortests', 'appointments': 'Termine', 'payments': 'Zahlungen',
      'archive': 'Archiv', 'images': 'Bilder', 'staff': 'Personal',
      'dashboard': 'Dashboard', 'patients': 'Patienten', 'tests': 'Tests',
      'reports': 'Berichte', 'settings': 'Einstellungen',
      'language_selection': 'Sprache', 'choose_language': 'Sprache wählen',
      'privacy_policy': 'Datenschutz', 'terms_of_service': 'Nutzungsbedingungen',
      'logout': 'Abmelden', 'profile': 'Profil', 'retry': 'Wiederholen',
    },
    AppLanguage.portuguese: {
      ..._en,
      'menu': 'Menu', 'home': 'Início', 'more': 'Mais', 'more_modules': 'Mais módulos',
      'lab_management': 'Gestão do laboratório', 'log_out': 'Sair',
      'lab_tests': 'Testes lab', 'appointments': 'Consultas', 'payments': 'Pagamentos',
      'archive': 'Arquivo', 'images': 'Imagens', 'staff': 'Equipe',
      'dashboard': 'Painel', 'patients': 'Pacientes', 'tests': 'Testes',
      'reports': 'Relatórios', 'settings': 'Configurações',
      'language_selection': 'Idioma', 'choose_language': 'Escolher idioma',
      'privacy_policy': 'Política de privacidade', 'terms_of_service': 'Termos de serviço',
      'logout': 'Sair', 'profile': 'Perfil', 'retry': 'Tentar novamente',
    },
    AppLanguage.chinese: {
      ..._en,
      'menu': '菜单', 'home': '首页', 'more': '更多', 'more_modules': '更多模块',
      'lab_management': '实验室管理', 'log_out': '退出登录',
      'lab_tests': '化验', 'appointments': '预约', 'payments': '付款',
      'archive': '存档', 'images': '图片', 'staff': '员工',
      'dashboard': '仪表板', 'patients': '患者', 'tests': '检测',
      'reports': '报告', 'settings': '设置',
      'language_selection': '语言', 'choose_language': '选择语言',
      'privacy_policy': '隐私政策', 'terms_of_service': '服务条款',
      'logout': '退出', 'profile': '个人资料', 'retry': '重试',
    },
    AppLanguage.turkish: {
      ..._en,
      'menu': 'Menü', 'home': 'Ana sayfa', 'more': 'Daha fazla', 'more_modules': 'Diğer modüller',
      'lab_management': 'Laboratuvar yönetimi', 'log_out': 'Çıkış',
      'lab_tests': 'Lab testleri', 'appointments': 'Randevular', 'payments': 'Ödemeler',
      'archive': 'Arşiv', 'images': 'Görseller', 'staff': 'Personel',
      'dashboard': 'Kontrol paneli', 'patients': 'Hastalar', 'tests': 'Testler',
      'reports': 'Raporlar', 'settings': 'Ayarlar',
      'language_selection': 'Dil', 'choose_language': 'Dil seçin',
      'privacy_policy': 'Gizlilik politikası', 'terms_of_service': 'Hizmet şartları',
      'logout': 'Çıkış', 'profile': 'Profil', 'retry': 'Tekrar dene',
    },
    AppLanguage.bengali: {
      ..._en,
      'menu': 'মেনু', 'home': 'হোম', 'more': 'আরও', 'more_modules': 'আরও মডিউল',
      'lab_management': 'ল্যাব ব্যবস্থাপনা', 'log_out': 'লগ আউট',
      'lab_tests': 'ল্যাব পরীক্ষা', 'appointments': 'অ্যাপয়েন্টমেন্ট', 'payments': 'পেমেন্ট',
      'archive': 'আর্কাইভ', 'images': 'ছবি', 'staff': 'কর্মী',
      'dashboard': 'ড্যাশবোর্ড', 'patients': 'রোগী', 'tests': 'পরীক্ষা',
      'reports': 'রিপোর্ট', 'settings': 'সেটিংস',
      'language_selection': 'ভাষা', 'choose_language': 'ভাষা নির্বাচন',
      'privacy_policy': 'গোপনীয়তা নীতি', 'terms_of_service': 'সেবার শর্তাবলী',
      'logout': 'লগ আউট', 'profile': 'প্রোফাইল', 'retry': 'আবার চেষ্টা',
    },
  };
}

extension AppLocalizations on BuildContext {
  String tr(String key) => read<LanguageProvider>().getText(key);
}
