import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/api/services/schedule_api.dart';

import 'package:tamdansers_lv2/core/widgets/card/custom_attendance_card.dart';
import 'package:tamdansers_lv2/core/widgets/card/parent_card_progress.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';

import 'package:tamdansers_lv2/data/model/attendance_model.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';
import 'package:tamdansers_lv2/data/model/schedule_model.dart';

import 'package:tamdansers_lv2/screens/parent/parent_dashboard/'
    'parent_attendance_tab/parent_attendance_tab_controller.dart';

part 'parent_home_tab_binding.dart';
part 'parent_home_tab_controller.dart';

class ParentHomeTabView extends GetView<ParentHomeTabViewController> {
  const ParentHomeTabView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ===================================================
              // Pinned top header
              // ===================================================

              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                toolbarHeight: 90,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                titleSpacing: 16,
                title: _buildTopHeader(),
              ),

              // ===================================================
              // Header content
              // ===================================================

              SliverToBoxAdapter(
                child: _buildHeaderContent(),
              ),

              // ===================================================
              // Main page content
              // ===================================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTodayScheduleSection(),
                      const SizedBox(height: 24),
                      _buildAttendanceCard(),
                      const SizedBox(height: 24),
                      _buildRecentAttendance(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Header content
  // =====================================================

  Widget _buildHeaderContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        22,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.getCurrentDate(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _buildChildSection(),
          const SizedBox(height: 20),
          ParentCardProgress(),
        ],
      ),
    );
  }

  // =====================================================
  // Top header
  // =====================================================

  Widget _buildTopHeader() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () {
              if (controller.isLoading.value) {
                return const CustomHeaderPlaceholder();
              }

              return CustomHeader(
                controller: controller.userController,
                textColor: AppColors.white,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        const CustomHeaderAction(),
      ],
    );
  }

  // =====================================================
  // Child selector
  // =====================================================

  Widget _buildChildSection() {
    return Obx(() {
      if (controller.students.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(
              alpha: 0.14,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.white.withValues(
                alpha: 0.30,
              ),
            ),
          ),
          child: Text(
            'dont_have_child'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '${'hello_parent'.tr} ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  controller.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 62,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedChild.value,
                isExpanded: true,
                menuMaxHeight: 300,
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.info,
                  size: 28,
                ),
                selectedItemBuilder: (context) {
                  return controller.students.map(
                    (student) {
                      return _buildSelectedChild(
                        student,
                      );
                    },
                  ).toList();
                },
                items: controller.students.map(
                  (student) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: student,
                      child: _buildDropdownChild(
                        student,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (child) {
                  if (child != null) {
                    controller.selectChild(
                      child,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSelectedChild(
    Map<String, dynamic> student,
  ) {
    final name = student['student_name']?.toString() ?? '-';
    final code = student['student_code']?.toString() ?? '-';

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.info.withValues(
            alpha: 0.12,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.info,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownChild(
    Map<String, dynamic> student,
  ) {
    final name = student['student_name']?.toString() ?? '-';
    final code = student['student_code']?.toString() ?? '-';

    final selectedId = controller.selectedChild.value?['id'];

    final isSelected =
        selectedId?.toString() == student['id']?.toString();

    return SizedBox(
      height: 58,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: isSelected
                ? AppColors.info
                : AppColors.info.withValues(
                    alpha: 0.12,
                  ),
            child: Icon(
              Icons.person_outline_rounded,
              color: isSelected
                  ? AppColors.white
                  : AppColors.info,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.info
                        : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.info,
              size: 20,
            ),
        ],
      ),
    );
  }

  // =====================================================
  // Attendance summary card
  // =====================================================

  Widget _buildAttendanceCard() {
    return Obx(() {
      final attendanceController =
          controller.attendanceController;

      if (attendanceController.isLoading.value &&
          attendanceController.attendanceList.isEmpty) {
        return Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          ),
        );
      }

      return CustomAttendanceCard(
        totalDays: attendanceController.totalDays,
        presentDays:
            attendanceController.presentDays.value,
        absentDays:
            attendanceController.absentDays.value,
        permissionDays:
            attendanceController.permissionDays.value,
        presentSubjects:
            attendanceController.presentSubjects.value,
        absentSubjects:
            attendanceController.absentSubjects.value,
        permissionSubjects:
            attendanceController.permissionSubjects.value,
        attendanceRate:
            attendanceController.attendanceRate,
        currentMonth:
            attendanceController.currentMonthName,
      );
    });
  }

  // =====================================================
  // Today's attendance
  // =====================================================

  Widget _buildRecentAttendance() {
    return Obx(() {
      final attendanceController =
          controller.attendanceController;

      final now = DateTime.now();

      final todayAttendance =
          attendanceController.attendanceList.where(
        (attendance) {
          final attendanceDate =
              DateTime.tryParse(attendance.date);

          if (attendanceDate == null) {
            return false;
          }

          return attendanceDate.year == now.year &&
              attendanceDate.month == now.month &&
              attendanceDate.day == now.day;
        },
      ).toList();

      todayAttendance.sort(
        (a, b) {
          final firstTime =
              _timeToMinutes(a.startTime);

          final secondTime =
              _timeToMinutes(b.startTime);

          return firstTime.compareTo(
            secondTime,
          );
        },
      );

      if (attendanceController.isLoading.value &&
          todayAttendance.isEmpty) {
        return const SizedBox.shrink();
      }

      if (todayAttendance.isEmpty) {
        return _buildAttendanceEmptyState();
      }

      final canExpand = todayAttendance.length > 2;

      final isExpanded =
          controller.isAttendanceExpanded.value;

      final visibleItems = isExpanded
          ? todayAttendance
          : todayAttendance.take(2).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'attendance_today'.tr,
                  style:
                      AppTextStyles.titleSmall.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (canExpand)
                InkWell(
                  borderRadius:
                      BorderRadius.circular(10),
                  onTap:
                      controller.toggleAttendanceExpanded,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded
                              ? 'បង្ហាញតិច'
                              : 'មើលទាំងអស់',
                          style: AppTextStyles
                              .bodySmall
                              .copyWith(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons
                                  .keyboard_arrow_up_rounded
                              : Icons
                                  .keyboard_arrow_down_rounded,
                          size: 20,
                          color:
                              AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeInOut,
            child: Column(
              children: visibleItems.map(
                (attendance) {
                  return _buildHomeAttendanceItem(
                    attendance,
                  );
                },
              ).toList(),
            ),
          ),
        ],
      );
    });
  }

  // =====================================================
  // Attendance item
  // =====================================================

  Widget _buildHomeAttendanceItem(
    AttendanceModel attendance,
  ) {
    final attendanceController =
        controller.attendanceController;

    final statusColor =
        attendanceController.getStatusColor(
      attendance.status,
    );

    final statusText =
        attendanceController.getStatusText(
      attendance.status,
    );

    final subjectName =
        attendance.subjectName.trim().isEmpty
            ? '-'
            : attendance.subjectName.trim();

    final className =
        attendance.className.trim().isEmpty
            ? '-'
            : attendance.className.trim();

    final teacherName =
        attendance.teacherName.trim().isEmpty
            ? '-'
            : attendance.teacherName.trim();

    final remark = attendance.remark.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 27,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$subjectName - $className',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles
                          .titleMedium
                          .copyWith(
                        color: AppColors.dark,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${'teacher'.tr}: $teacherName',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles
                          .bodySmall
                          .copyWith(
                        color:
                            AppColors.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Text(
                  statusText,
                  style:
                      AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  attendanceController.formatDate(
                    attendance.date,
                  ),
                  style:
                      AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 7),
              Text(
                _formatTimeRange(
                  attendance.startTime,
                  attendance.endTime,
                ),
                style:
                    AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          if (remark.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 17,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    remark,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // Attendance empty state
  // =====================================================

  Widget _buildAttendanceEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attendance_today'.tr,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 38,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  size: 35,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                'មិនមានទិន្នន័យវត្តមានថ្ងៃនេះ',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'ទិន្នន័យវត្តមានថ្ងៃនេះនឹងបង្ហាញនៅទីនេះ',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // Schedule section
  // =====================================================

  Widget buildTodayScheduleSection() {
    return Obx(() {
      if (controller.isScheduleLoading.value) {
        return _buildScheduleLoading();
      }

      if (controller.scheduleError.value.isNotEmpty) {
        return _buildScheduleError();
      }

      if (controller.todaySchedule.isEmpty) {
        return _buildScheduleEmpty();
      }

      final visibleSchedules =
          controller.todaySchedule.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'today_schedule'.tr,
                  style:
                      AppTextStyles.titleSmall.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.todaySchedule.length} session',
                  style:
                      AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visibleSchedules.map(
            scheduleCard,
          ),
        ],
      );
    });
  }

  Widget _buildScheduleLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'កាលវិភាគថ្ងៃនេះ',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (index) {
            return Container(
              width: double.infinity,
              height: 135,
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'កាលវិភាគថ្ងៃនេះ',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ថ្ងៃនេះមិនមានកាលវិភាគទេ',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'កាលវិភាគសិក្សាប្រចាំថ្ងៃនឹងបង្ហាញនៅទីនេះ',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            'មិនអាចទាញយកកាលវិភាគបាន',
            textAlign: TextAlign.center,
            style:
                AppTextStyles.bodyMedium.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              final studentId =
                  controller.selectedChild.value?['id'];

              final parsedId = int.tryParse(
                studentId?.toString() ?? '',
              );

              if (parsedId != null) {
                controller.getTodaySchedule(
                  parsedId,
                );
              }
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'ព្យាយាមម្ដងទៀត',
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // Schedule card
  // =====================================================

  Widget scheduleCard(
    ScheduleModel item,
  ) {
    final theme = Get.theme;

    final subject =
        item.subjectName.trim().isEmpty
            ? '-'
            : item.subjectName.trim();

    final teacher =
        item.teacherName.trim().isEmpty
            ? '-'
            : item.teacherName.trim();

    final isMorning = controller.isMorning(
      item.startTime,
    );

    final accentBackground = isMorning
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;

    final accentTextColor = isMorning
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SubjectUi.bgColor(
                    subject,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  SubjectUi.icon(
                    subject,
                  ),
                  color: SubjectUi.color(
                    subject,
                  ),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles
                          .titleSmall
                          .copyWith(
                        color: AppColors.dark,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'teacher'.tr}: $teacher',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles
                          .bodyMedium
                          .copyWith(
                        color:
                            AppColors.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: accentBackground,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: accentTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${controller.formatTime(item.startTime)}'
                          ' - '
                          '${controller.formatTime(item.endTime)}',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: AppTextStyles
                              .bodySmall
                              .copyWith(
                            color:
                                accentTextColor,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Text(
                  isMorning
                      ? 'morning'.tr
                      : 'afternoon'.tr,
                  style:
                      AppTextStyles.bodySmall.copyWith(
                    color: accentTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (item.room.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 18,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${'room'.tr}: ${item.room}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: AppTextStyles
                        .bodyMedium
                        .copyWith(
                      color:
                          AppColors.neutral500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // Time helpers
  // =====================================================

  String _formatTimeRange(
    String startTime,
    String endTime,
  ) {
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);

    if (start.isEmpty && end.isEmpty) {
      return '-';
    }

    if (start.isEmpty) {
      return end;
    }

    if (end.isEmpty) {
      return start;
    }

    return '$start - $end';
  }

  String _formatTime(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return '';
    }

    final parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    return '${parts[0]}:${parts[1]}';
  }

  int _timeToMinutes(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return 0;
    }

    final parts = text.split(':');

    if (parts.length < 2) {
      return 0;
    }

    final hour =
        int.tryParse(parts[0]) ?? 0;

    final minute =
        int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }
}