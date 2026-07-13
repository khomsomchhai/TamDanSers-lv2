import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_attendance_card.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_function_card.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';

part 'home_tab_binding.dart';
part 'home_tab_controller.dart';

class HomeTabView extends GetView<HomeTabViewController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => controller.userController.isLoading.value
                      ? CustomHeaderPlaceholder()
                      : CustomHeader(controller: controller.userController),),
                    ),
                    const SizedBox(width: 10,),
                    CustomHeaderAction(
                      onTapNotification: () {
                      
                      },
                      unreadCount: 2,
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                Text(
                  controller.getCurrentDate(),
                  style: Get.textTheme.bodyLarge,
                ),
                const SizedBox(height: 10,),
                Obx(() => controller.userController.isLoading.value
                ? _buildAttendanceCardSkeleton()
                : _buildAttendanceCard()
                ),
                const SizedBox(height: 20,),
                _buildFunction(),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Text(
                      "attendance".tr,
                      style: Get.textTheme.titleSmall,
                    ),
                    Spacer(),
                    Text(
                      "see all".tr,
                      style: Get.textTheme.bodyMedium!.copyWith(color: AppColors.info),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFunction() {
    return Row(
      children: [
        Expanded(child: Bounceable(
          onTap: () {
            Get.toNamed(AppRoutes.askPermissionScreen);
          },
          child: CustomFunctionCard(
            title: "ask_permission".tr,
            icon: Image.asset(
              AppIcons.permissionIcon,
              width: 50,
              height: 50,
            ),
          ),
        )),
        const SizedBox(width: 20,),
        Expanded(child: Bounceable(
          onTap: () {
            Get.toNamed(AppRoutes.scheduleScreen);
          },
          child: CustomFunctionCard(
            title: "schedule".tr,
            icon: Image.asset(
              AppIcons.scheduleIcon,
              width: 50,
              height: 50,
            ),
          ),
        )),
        const SizedBox(width: 20,),
        Expanded(child: Bounceable(
          onTap: () {
            Get.toNamed(AppRoutes.resultScreen);
          },
          child: CustomFunctionCard(
            title: "result".tr,
            icon: Image.asset(
              AppIcons.resultIcon,
              width: 50,
              height: 50,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAttendanceCard() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "class".tr,
              style: Get.textTheme.titleSmall,
            ),
            Text(
              controller.userController.profile!.className,
              style: Get.textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 10,),
        CustomAttendanceCard(
          totalDays: 9, 
          presentDays: 5, 
          absentDays: 4, 
          attendanceRate: 87, 
          currentMonth: "មិថុនា"
        )
      ],
    );
  }
  Widget _buildAttendanceCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBaseColor,
      highlightColor: AppColors.skeletonHighlightColor,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 140, 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}