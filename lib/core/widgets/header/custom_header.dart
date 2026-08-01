import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    required this.controller,
    this.textColor,
  });

  final UserController controller;

  /// បើផ្ញើ textColor វានឹងប្រើពណ៌នោះ
  /// បើមិនផ្ញើ វានឹងយកពណ៌តាម Theme
  final Color? textColor;

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'good_morning'.tr;
    }

    if (hour >= 12 && hour < 17) {
      return 'good_afternoon'.tr;
    }

    if (hour >= 17 && hour < 21) {
      return 'good_evening'.tr;
    }

    return 'good_night'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final user = controller.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final avatarUrl = user.avatarUrl?.trim();

    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final defaultTextColor = isDarkMode
        ? AppColors.white
        : AppColors.dark;

    final resolvedTextColor =
        textColor ?? defaultTextColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.skeletonBaseColor,
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Icon(
                  Icons.person_rounded,
                  size: 30,
                  color: resolvedTextColor,
                )
              : null,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                getGreeting(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: resolvedTextColor.withValues(
                    alpha: 0.80,
                  ),
                  height: 1.1,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                user.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.titleSmall?.copyWith(
                  color: resolvedTextColor,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}