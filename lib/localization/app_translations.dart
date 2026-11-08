import 'package:get/get.dart';
import 'ar_sa.dart';
import 'en_us.dart';

/// Centralized localization for the application.
/// Allows adding additional languages effortlessly.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'en': enUS,
    'ar_SA': arAR,
    'ar': arAR,
  };

  static const Map<String, String> enUS = enTranslations;
  static const Map<String, String> arAR = arTranslations;
}
