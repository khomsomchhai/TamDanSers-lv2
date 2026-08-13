import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/attendance_tab/attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/home_tab/home_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/profile_tab/profile_tab_view.dart';

part 'student_dashboard_binding.dart';
part 'student_dashboard_controller.dart';

class StudentDashboardView extends GetView<StudentDashboardViewController> {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            HomeTabView(),
            HomeworkView(),
            AttendanceTabView(),
            ProfileTabView(),
          ],
        ),
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 12),
          child: FloatingActionButton(
            onPressed: controller.scanAttendance,
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: Theme.of(context).colorScheme.surface,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, PhosphorIconsRegular.house,
                      PhosphorIconsFill.house, "home".tr),
                  _buildNavItem(context, 1, PhosphorIconsRegular.clipboardText,
                      PhosphorIconsFill.clipboardText, "homework".tr),
                  const SizedBox(width: 60),
                  _buildNavItem(context, 2, PhosphorIconsRegular.calendarCheck,
                      PhosphorIconsFill.calendarCheck, "attendance".tr),
                  _buildNavItem(context, 3, PhosphorIconsRegular.user,
                      PhosphorIconsFill.user, "profile".tr),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData regularIcon,
    IconData fillIcon,
    String label,
  ) {
    final isActive = controller.currentIndex.value == index;
    final color = isActive ? AppColors.primary : AppColors.grey;
    return InkWell(
      onTap: () => controller.changeTab(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? fillIcon : regularIcon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style:
                  Get.textTheme.bodySmall?.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
