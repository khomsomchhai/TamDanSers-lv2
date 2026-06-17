import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService {
  var box = GetStorage();
  Locale getLocale(){
    var lang = box.read("lang") ?? "km";
    return Locale(lang);
  }

  void changeLocale(String lang){
    box.write("lang", lang);
    Get.updateLocale(Locale(lang));
  }
}