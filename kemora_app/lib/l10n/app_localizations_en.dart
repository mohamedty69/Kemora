// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'World Travel Guide';

  @override
  String get exploreEgypt => 'Explore Egypt';

  @override
  String get searchHint => 'Search for specific city...';

  @override
  String get hotels => 'Hotels';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get museums => 'Museums';

  @override
  String get others => 'Others';

  @override
  String get viewAll => 'View All';

  @override
  String get events => 'Events';

  @override
  String get comments => 'Comments';

  @override
  String get achievements => 'Achievements';

  @override
  String get seeAll => 'See All';

  @override
  String get rewards => 'Rewards';

  @override
  String discount(String percent) {
    return '$percent% Discount';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';
}
