import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';

class CustomHeaderAction extends StatelessWidget {
  final VoidCallback onTapNotification;
  const CustomHeaderAction({
    super.key,
    required this.onTapNotification
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
          borderRadius:
              BorderRadius.circular(AppNumbers.radiusMedium),
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
          width: 6,
        ),
        Bounceable(
          onTap: () {
            onTapNotification;
          },
          child: Icon(
            Icons.notifications_rounded,
            size: 28,
          )
        )
      ],
    );
  }
}