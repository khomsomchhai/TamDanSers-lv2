import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class TelegramService {

  Future<void> connectTelegram(String phone) async {
    try {
      final uri = Uri.parse(
        'https://t.me/tamdansersbot?start=link_$phone',
      );

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        CustomSnackbar.error(
          'Could not open Telegram.'.tr,
        );
      }
    } catch (e) {
      CustomSnackbar.error(
        'Something went wrong.'.tr,
      );
    }
  }

}