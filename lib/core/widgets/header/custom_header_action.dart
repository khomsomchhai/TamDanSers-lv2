import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';

class CustomHeaderAction extends StatelessWidget {
  final VoidCallback? onTapNotification;
  final int unreadCount;

  const CustomHeaderAction({
    super.key,
    this.onTapNotification,
    this.unreadCount = 0,
  });

  void _openNotification() {
    debugPrint("Notification button tapped");
    Get.toNamed(AppRoutes.notificationScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final currentLang = Get.locale?.languageCode ?? 'en';
            final nextLang = currentLang == 'km' ? 'en' : 'km';
            LocalizationService().changeLocale(nextLang);
          },
          child: Image.asset(
            Get.locale?.languageCode == 'km'
                ? AppIcons.khmerIcon
                : AppIcons.englishIcon,
            width: 24,
          ),
        ),
        const SizedBox(width: 6,),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapNotification ?? _openNotification,
          child: SizedBox(
            width: 28,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  PhosphorIconsRegular.bell,
                  size: 28,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: 2,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration:  BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? "99+" : unreadCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}