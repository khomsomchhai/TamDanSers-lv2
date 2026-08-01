import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/skeleton_theme.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';
import 'package:tamdansers_lv2/core/api/services/schedule_services.dart';
import 'package:tamdansers_lv2/core/widgets/card/attendance_card.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_function_card.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_score_card.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';
import 'package:tamdansers_lv2/data/model/schedule_model.dart';
import 'package:tamdansers_lv2/screens/notification/notification_view.dart';
import 'package:tamdansers_lv2/screens/student/result_screen/result_screen_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/student_dashboard_view.dart';

part 'home_tab_binding.dart';
part 'home_tab_controller.dart';

class HomeTabView extends GetView<HomeTabViewController> {
  HomeTabView({super.key});
  final resultController = Get.put(ResultScreenViewController());

  final NotificationController notificationController =
      Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshHome,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => controller.userController.isLoading.value
                              ? CustomHeaderPlaceholder()
                              : CustomHeader(
                                  controller: controller.userController),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(
                        () => CustomHeaderAction(
                          unreadCount: notificationController.unreadCount.value,
                          onTapNotification: () {
                            notificationController.markAllRead();

                            Get.toNamed(AppRoutes.notificationScreen);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    controller.getCurrentDate(),
                    style: Get.textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => controller.userController.isLoading.value
                      ? _buildAttendanceCardSkeleton()
                      : _buildAttendanceCard()),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildFunction(),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTodayScheduleSection(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "attendance".tr,
                        style: Get.textTheme.titleSmall,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.find<StudentDashboardViewController>()
                              .changeTab(2);
                        },
                        child: Text(
                          "see_all".tr,
                          style: Get.textTheme.bodyMedium!
                              .copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppNumbers.spacingMedium),
                  Obx(() {
                    if (controller.isLoadingAttendance.value) {
                      return _buildRecentAttendanceSkeleton();
                    }

                    if (controller.recentAttendance.isEmpty) {
                      return SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            'attendance_no_records'.tr,
                            style: Get.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          ...controller.recentAttendance.map((item) {
                            final index = controller.recentAttendance.indexOf(item);
                            return Column(
                              children: [
                                AttendanceCard(
                                  item: item,
                                  mapStatus: controller.mapStatus,
                                  statusColor: controller.mapStatusColor,
                                  formatDate: controller.formatDate,
                                  formatTimeRange: controller.formatTimeRange,
                                ),
                                if (index < controller.recentAttendance.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFunction() {
    return Row(
      children: [
        Expanded(
            child: Bounceable(
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
        const SizedBox(
          width: 20,
        ),
        Expanded(
            child: Bounceable(
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
        const SizedBox(
          width: 20,
        ),
        Expanded(
            child: Bounceable(
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
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          if (resultController.isLoading.value) {
            return _buildAttendanceCardSkeleton();
          }

          return CustomScoreCard();
        })
      ],
    );
  }

  Widget _buildAttendanceCardSkeleton() {
    final skeletonTheme = Get.theme.extension<SkeletonTheme>();
    return Shimmer.fromColors(
      baseColor: skeletonTheme?.baseColor ?? Get.theme.cardColor,
      highlightColor: skeletonTheme?.highlightColor ?? Colors.grey.shade200,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 14,
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
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
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAttendanceSkeleton() {
    final skeletonTheme = Get.theme.extension<SkeletonTheme>();
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppNumbers.spacingMedium),
          child: Shimmer.fromColors(
            baseColor: skeletonTheme?.baseColor ?? Get.theme.cardColor,
            highlightColor: skeletonTheme?.highlightColor ?? Colors.grey.shade200,
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppNumbers.cardPadding),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final isExpanded = controller.isExpandedSchedule.value;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "today_schedule".tr,
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (controller.todaySchedules.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    controller.toggleScheduleExpand();
                  },
                  child: Text(
                    isExpanded ? "see_less".tr : "see_all".tr,
                    style: Get.textTheme.bodyMedium!
                        .copyWith(color: AppColors.info),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.isLoadingSchedule.value) {
            return _buildTodayScheduleSkeleton();
          }

          if (controller.todaySchedules.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'no_schedule_for'
                      .trParams({'day': controller._getTodayDayName()}),
                  style:
                      Get.textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final listToDisplay = controller.visibleSchedules;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listToDisplay.length,
            itemBuilder: (context, index) {
              final item = listToDisplay[index];
              final isLast = index == listToDisplay.length - 1;
              return _buildScheduleTimelineItem(item, isLast: isLast);
            },
          );
        }),
      ],
    );
  }

  Widget _buildScheduleTimelineItem(ScheduleModel item,
      {required bool isLast}) {
    final timeParsed = controller.parseTimePill(item.startTime);
    final timeStr = timeParsed['time']!;
    final periodStr = timeParsed['period']!;

    final subjectColor = SubjectUi.color(item.subjectName);
    final subjectBg = SubjectUi.bgColor(item.subjectName);
    final subjectIcon = SubjectUi.icon(item.subjectName);

    final teacherName = item.teacherName.isNotEmpty ? item.teacherName : '';

    final hasRoom = item.room.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Pill + Vertical Connecting Line
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: subjectBg,
                    borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: subjectColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (periodStr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          periodStr,
                          style: TextStyle(
                            color: subjectColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 1.5,
                        decoration: BoxDecoration(
                          color: Get.theme.dividerColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Creative Content Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                border: Border.all(color: Get.theme.dividerColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left Subject Accent Strip
                      Container(
                        width: 5,
                        color: subjectColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  // Subject Icon Badge
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: subjectBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      subjectIcon,
                                      size: 16,
                                      color: subjectColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Subject Name
                                  Expanded(
                                    child: Text(
                                      item.subjectName,
                                      style:
                                          Get.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Get.theme.textTheme.titleMedium?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (teacherName.isNotEmpty ||
                                  hasRoom ||
                                  item.endTime.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 14,
                                  runSpacing: 4,
                                  children: [
                                    if (teacherName.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.person_outline_rounded,
                                            size: 15,
                                            color: Get.theme.hintColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            teacherName,
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Get.theme.hintColor,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (hasRoom)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.meeting_room_outlined,
                                            size: 15,
                                            color: Get.theme.hintColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.room,
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Get.theme.hintColor,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (item.endTime.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.schedule_outlined,
                                            size: 15,
                                            color: Get.theme.hintColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Until ${controller.parseTimePill(item.endTime)['time']} ${controller.parseTimePill(item.endTime)['period']}',
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Get.theme.hintColor,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleSkeleton() {
    final skeletonTheme = Get.theme.extension<SkeletonTheme>();
    return Shimmer.fromColors(
      baseColor: skeletonTheme?.baseColor ?? Get.theme.cardColor,
      highlightColor: skeletonTheme?.highlightColor ?? Colors.grey.shade200,
      child: Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Get.theme.cardColor,
                    borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
