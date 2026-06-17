import 'package:get/get_navigation/get_navigation.dart';
import 'package:tamdansers_lv2/app/localization/languages/en_us.dart';
import 'package:tamdansers_lv2/app/localization/languages/km_kh.dart';

class AppTranslation extends Translations{
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enUs,
    'km': kmKh,
  };
}
