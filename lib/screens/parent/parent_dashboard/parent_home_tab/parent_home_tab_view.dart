import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_attendance_card.dart';
import 'package:tamdansers_lv2/core/widgets/card/parent_card_progress.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';
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
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                expandedHeight: screenHeight * 0.43,
                backgroundColor: AppColors.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _buildHeader(),
                ),
              ),
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
                      
                      const SizedBox(height: 14),
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

  Widget _buildAttendanceCard() {
    return Obx(() {
      final attendanceController = controller.attendanceController;

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
        presentDays: attendanceController.presentDays.value,
        absentDays: attendanceController.absentDays.value,
        permissionDays: attendanceController.permissionDays.value,
        presentSubjects: attendanceController.presentSubjects.value,
        absentSubjects: attendanceController.absentSubjects.value,
        permissionSubjects: attendanceController.permissionSubjects.value,
        attendanceRate: attendanceController.attendanceRate,
        currentMonth: attendanceController.currentMonthName,
      );
    });
  }

  Widget _buildRecentAttendance() {
    return Obx(() {
      final attendanceController = controller.attendanceController;

      final attendanceList = attendanceController.attendanceList.toList();

      attendanceList.sort((a, b) {
        final firstDate = DateTime.tryParse(
              a.date.toString() ?? '',
            ) ??
            DateTime(2000);

        final secondDate = DateTime.tryParse(
              b.date.toString() ?? '',
            ) ??
            DateTime(2000);

        return secondDate.compareTo(
          firstDate,
        );
      });

      if (attendanceController.isLoading.value && attendanceList.isEmpty) {
        return const SizedBox.shrink();
      }

      if (attendanceList.isEmpty) {
        return _buildAttendanceEmptyState();
      }

      final recentItems = attendanceList.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ប្រវត្តិវត្តមានថ្មីៗ',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${attendanceList.length} កំណត់ត្រា',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentItems.map(
            (attendance) {
              final status = attendanceController.normalizeStatus(
                attendance.status,
              );

              final color = attendanceController.getStatusColor(
                attendance.status,
              );

              final title = attendanceController.getStatusText(
                attendance.status,
              );

              final icon = attendanceController.getStatusIcon(
                attendance.status,
              );

              final remark = attendance.remark.toString().trim() ?? '';

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                padding: const EdgeInsets.all(
                  14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dark.withValues(
                        alpha: 0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.dark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.hintColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                attendanceController.formatDate(
                                  attendance.date,
                                ),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.hintColor,
                                ),
                              ),
                            ],
                          ),
                          if (remark.isNotEmpty) ...[
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              remark,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        _getShortStatus(
                          status,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildAttendanceEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 42,
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'មិនមានទិន្នន័យវត្តមាន',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ទិន្នន័យវត្តមានរបស់សិស្សនឹងបង្ហាញនៅទីនេះ',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortStatus(
    String status,
  ) {
    switch (status) {
      case 'p':
      case 'present':
        return 'P';

      case 'a':
      case 'absent':
        return 'A';

      case 'l':
      case 'leave':
      case 'permission':
      case 'permitted':
        return 'L';

      default:
        return '-';
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
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
          _buildTopHeader(),
          const SizedBox(height: 14),
          Text(
            controller.getCurrentDate(),
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withValues(
                alpha: 0.85,
              ),
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

  Widget _buildTopHeader() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => controller.isLoading.value
                ? const CustomHeaderPlaceholder()
                : CustomHeader(
                    controller: controller.userController,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        const CustomHeaderAction(),
      ],
    );
  }

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
              color: AppColors.white,
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
              Expanded(
                child: Text(
                  '${'hello_parent'.tr} ${controller.childName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
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
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedChild.value,
                isExpanded: true,
                menuMaxHeight: 300,
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(
                  16,
                ),
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

    final isSelected = selectedId?.toString() == student['id']?.toString();

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
              color: isSelected ? AppColors.white : AppColors.info,
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
                    color: isSelected ? AppColors.info : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  code,
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
}
