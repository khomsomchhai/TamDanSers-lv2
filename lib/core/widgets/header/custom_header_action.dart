import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';

class CustomHeaderAction extends StatelessWidget {
  final VoidCallback onTapNotification;
  final int unreadCount;

  const CustomHeaderAction({
    super.key,
    required this.onTapNotification,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: (lang) {
            LocalizationService().changeLocale(lang);
          },
          position: PopupMenuPosition.under,
          borderRadius: BorderRadius.circular(
            AppNumbers.radiusMedium,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Image.asset(
                      AppIcons.englishIcon,
                      width: 24,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "English",
                      style: Get.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'km',
                child: Row(
                  children: [
                    Image.asset(
                      AppIcons.khmerIcon,
                      width: 24,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "ភាសាខ្មែរ",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                  ],
                ),
              ),
            ];
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                Get.locale?.languageCode == 'km'
                    ? AppIcons.khmerIcon
                    : AppIcons.englishIcon,
                width: 24,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Bounceable(
          onTap: onTapNotification,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_rounded,
                size: 28,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 99
                          ? "99+"
                          : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}