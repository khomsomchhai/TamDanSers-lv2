import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_attendance_tab/parent_attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_home_tab/parent_home_tab_view.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_homework_tab/parent_homework_tab_view.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_profile_tab/parent_profile_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/profile_tab/profile_tab_view.dart';

part 'parent_dashboard_binding.dart';
part 'parent_dashboard_controller.dart';

class ParentDashboardView extends GetView<ParentDashboardViewController> {
  const ParentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children:  [
            ParentHomeTabView(),
            ParentHomeworkTabView(),
            ParentAttendanceTabView(),
            ParentProfileTabView()
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.house),
                activeIcon: Icon(PhosphorIconsFill.house),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.clipboardText),
                activeIcon: Icon(PhosphorIconsFill.clipboardText),
                label: 'homework'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.calendarCheck),
                activeIcon: Icon(PhosphorIconsFill.calendarCheck),
                label: 'attendance'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.user),
                activeIcon: Icon(PhosphorIconsFill.user),
                label: 'profile'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
