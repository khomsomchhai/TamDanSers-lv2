import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    required this.controller,
  });

  final UserController controller;

  String getGreeting(){
    final hour = DateTime.now().hour;
    if(hour >= 5 && hour < 12){
      return "good_morning".tr;
    }else if(hour >= 12 && hour < 17){
      return "good_afternoon".tr;
    }else if(hour >= 17 && hour < 21){
      return "good_evening".tr;
    }else{
      return "good_night".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return controller.user == null? SizedBox.shrink(): Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.neutral500,
          radius: 24,
          onBackgroundImageError: (exception, stackTrace) => Image.asset("assets/images/app_logo.png"),
          backgroundImage: controller.user!.avatarUrl != null
              ? NetworkImage(controller.user!.avatarUrl!, )
              : null,
          child: controller.user!.avatarUrl == null
              ? const Icon(Icons.person, size: 38,)
              : null,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getGreeting(),
                style: Get.textTheme.bodySmall!
                    .copyWith(height: 1.2),
              ),
              Text(
                controller.user!.fullName,
                style: Get.textTheme.titleSmall!
                    .copyWith(height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ),
        SizedBox(
          width: 10,
        ),
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
          onTap: () {},
          child: Icon(
            Icons.notifications_rounded,
            size: 28,
          )
        )
      ],
    );
  }
}