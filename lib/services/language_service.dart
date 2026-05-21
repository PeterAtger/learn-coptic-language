import 'package:flutter/material.dart';

enum AppLanguage { ar, en }

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  AppLanguage _currentLanguage = AppLanguage.ar;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isArabic => _currentLanguage == AppLanguage.ar;

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  String getDataPath(String baseName) {
    if (isArabic) {
      return 'assets/data/$baseName.json';
    } else {
      return 'assets/data/${baseName}_en.json';
    }
  }

  String translate(String key) {
    if (_translations[key] == null) return key;
    return _translations[key]![_currentLanguage] ?? key;
  }

  static const Map<String, Map<AppLanguage, String>> _translations = {
    'app_title': {
      AppLanguage.ar: 'منهج القبطي - مهرجان الكرازة المرقسية',
      AppLanguage.en: 'Coptic Curriculum - Mahragan Al-Keraza',
    },
    'year_2026': {
      AppLanguage.ar: 'سنة ٢٠٢٦',
      AppLanguage.en: 'Year 2026',
    },
    'contact_us': {
      AppLanguage.ar: 'للتواصل معنا',
      AppLanguage.en: 'Contact Us',
    },
    'about_app': {
      AppLanguage.ar: 'عن التطبيق',
      AppLanguage.en: 'About the App',
    },
    'about_content': {
      AppLanguage.ar: 'هذا التطبيق تم بكل حب ومودة من أجلكم\nبواسطة خدام كنيسة الشهيد العظيم أبي سيفين والشهيدة دميانة بشبرا\n\nمهرجان الكرازة ٢٠٢٦',
      AppLanguage.en: 'This app was made with love, for you,\nby the servants of St. Mercurius & St. Demiana Church, Shubra.\n\nMahragan Al-Keraza 2026',
    },
    'close': {
      AppLanguage.ar: 'إغلاق',
      AppLanguage.en: 'Close',
    },
    'mina_joseph': {
      AppLanguage.ar: 'م. مينا چوزيف',
      AppLanguage.en: 'Eng. Mina Joseph',
    },
    'philopater_joseph': {
      AppLanguage.ar: 'م. فيلوباتير چوزيف',
      AppLanguage.en: 'Eng. Philopater Joseph',
    },
    'main_page': {
      AppLanguage.ar: 'الرئيسية',
      AppLanguage.en: 'Home',
    },
    'letters': {
      AppLanguage.ar: 'الحروف',
      AppLanguage.en: 'Letters',
    },
    'words': {
      AppLanguage.ar: 'الكلمات',
      AppLanguage.en: 'Words',
    },
    'hymns': {
      AppLanguage.ar: 'المحفوظات',
      AppLanguage.en: 'Hymns',
    },
    'no_hymns': {
      AppLanguage.ar: 'لا توجد محفوظات حالياً',
      AppLanguage.en: 'No hymns available currently',
    },
    'grammar': {
      AppLanguage.ar: 'القواعد',
      AppLanguage.en: 'Grammar',
    },
    'coptic_grammar': {
      AppLanguage.ar: 'قواعد اللغة القبطية',
      AppLanguage.en: 'Coptic Grammar Rules',
    },
    'no_grammar': {
      AppLanguage.ar: 'مفيش قواعد للمرحلة دي',
      AppLanguage.en: 'No grammar rules for this stage',
    },
    'bookmarks': {
      AppLanguage.ar: 'المحفوظة',
      AppLanguage.en: 'Bookmarks',
    },
    'bookmarks_title': {
      AppLanguage.ar: 'الآيات والمحفوظات',
      AppLanguage.en: 'Verses & Hymns',
    },
    'bookmarks_subtitle': {
      AppLanguage.ar: 'محفوظاتك الشخصية',
      AppLanguage.en: 'Your Personal Bookmarks',
    },
    'bookmarks_empty': {
      AppLanguage.ar: 'صفحة المحفوظات فاضية.\nاضغط على النجمة لحفظ أي جملة.',
      AppLanguage.en: 'Your bookmarks page is empty.\nTap the star to save any verse.',
    },
    // Stages
    'nursery': { AppLanguage.ar: 'حضانة', AppLanguage.en: 'Nursery' },
    'primary12': { AppLanguage.ar: 'أولى وتانية', AppLanguage.en: 'Primary 1 & 2' },
    'primary34': { AppLanguage.ar: 'تالتة ورابعة', AppLanguage.en: 'Primary 3 & 4' },
    'primary56': { AppLanguage.ar: 'خامسة وسادسة', AppLanguage.en: 'Primary 5 & 6' },
    'prep': { AppLanguage.ar: 'إعدادي', AppLanguage.en: 'Preparatory' },
    'sec': { AppLanguage.ar: 'ثانوي', AppLanguage.en: 'Secondary' },
    'qana': { AppLanguage.ar: 'قانا الجليل', AppLanguage.en: 'Cana of Galilee' },
    'uni': { AppLanguage.ar: 'جامعة', AppLanguage.en: 'University' },
    'graduates': { AppLanguage.ar: 'خريجين', AppLanguage.en: 'Graduates' },
    'servants': { AppLanguage.ar: 'خدام', AppLanguage.en: 'Servants' },
    'servants_trainees': { AppLanguage.ar: 'إعداد خدام', AppLanguage.en: 'Servants in Training' },
    'special_needs_simple': { AppLanguage.ar: 'ذوي الهمم (بسيط)', AppLanguage.en: 'Special Needs (Basic)' },
    'special_needs_average': { AppLanguage.ar: 'ذوي الهمم (متوسط)', AppLanguage.en: 'Special Needs (Intermediate)' },
    'special_needs_advanced': { AppLanguage.ar: 'ذوي الهمم (متميز)', AppLanguage.en: 'Special Needs (Advanced)' },
    'donation_title': {
      AppLanguage.ar: 'دعم الخدمة',
      AppLanguage.en: 'Support the Service',
    },
    'donation_desc': {
      AppLanguage.ar: 'للتبرع من اجل تطوير واستمرار الخدمة',
      AppLanguage.en: 'Donate to help us develop and sustain this service',
    },
    'open_instapay': {
      AppLanguage.ar: 'فتح رابط انستاباي المباشر',
      AppLanguage.en: 'Open Direct InstaPay Link',
    },
    'copy_link': {
      AppLanguage.ar: 'نسخ رابط التبرع',
      AppLanguage.en: 'Copy Donation Link',
    },
    'link_copied': {
      AppLanguage.ar: 'تم نسخ الرابط بنجاح!',
      AppLanguage.en: 'Link copied successfully!',
    },
    'banner_title': {
      AppLanguage.ar: 'دعم استمرار التطبيق',
      AppLanguage.en: 'Help Keep the App Going',
    },
    'banner_desc': {
      AppLanguage.ar: 'ساعدنا في تطوير الخدمة وتحديثها',
      AppLanguage.en: 'Help us develop and update the service',
    },
    'coptic_letters': {
      AppLanguage.ar: 'الحروف القبطية',
      AppLanguage.en: 'Coptic Letters',
    },
    'pronunciation_label': {
      AppLanguage.ar: 'نطق الحرف',
      AppLanguage.en: 'Pronunciation',
    },
    'search_letters': {
      AppLanguage.ar: 'ابحث عن حرف...',
      AppLanguage.en: 'Search for a letter...',
    },
    'coptic_words': {
      AppLanguage.ar: 'الكلمات القبطية',
      AppLanguage.en: 'Coptic Words',
    },
    'coptic_hymns': {
      AppLanguage.ar: 'المحفوظات القبطية',
      AppLanguage.en: 'Coptic Hymns',
    },
    'all_filter': {
      AppLanguage.ar: 'الكل',
      AppLanguage.en: 'All',
    },
    'toggle_coptic': {
      AppLanguage.ar: 'القبطي',
      AppLanguage.en: 'Coptic',
    },
    'toggle_pronunciation': {
      AppLanguage.ar: 'النطق',
      AppLanguage.en: 'Pronunciation',
    },
    'toggle_meaning': {
      AppLanguage.ar: 'المعنى',
      AppLanguage.en: 'Meaning',
    },
    'no_matches': {
      AppLanguage.ar: 'لا توجد كلمات مطابقة',
      AppLanguage.en: 'No matching words found',
    },
    'visibility_error': {
      AppLanguage.ar: 'مينفعش تخفي الـ 3 مع بعض',
      AppLanguage.en: 'You cannot hide all three at once',
    },
    'masculine': {
      AppLanguage.ar: 'مذكر',
      AppLanguage.en: 'Masc',
    },
    'feminine': {
      AppLanguage.ar: 'مؤنث',
      AppLanguage.en: 'Fem',
    },
    'verb': {
      AppLanguage.ar: 'فعل',
      AppLanguage.en: 'Verb',
    },
    'proper_noun': {
      AppLanguage.ar: 'اسم علم',
      AppLanguage.en: 'Name',
    },
    'number': {
      AppLanguage.ar: 'عدد',
      AppLanguage.en: 'Num',
    },
  };
}
