// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دليل السفر العالمي';

  @override
  String get exploreEgypt => 'استكشف مصر';

  @override
  String get searchHint => 'ابحث عن مدينة محددة...';

  @override
  String get hotels => 'فنادق';

  @override
  String get restaurants => 'مطاعم';

  @override
  String get museums => 'متاحف';

  @override
  String get others => 'أخرى';

  @override
  String get viewAll => 'رؤية الكل';

  @override
  String get events => 'أحداث';

  @override
  String get comments => 'التعليقات';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get seeAll => 'مشاهدة الكل';

  @override
  String get rewards => 'الجوائز';

  @override
  String discount(String percent) {
    return 'خصم $percent%';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';
}
