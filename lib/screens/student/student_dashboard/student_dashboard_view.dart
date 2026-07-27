import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/attendance_tab/attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/home_tab/home_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/profile_tab/profile_tab_view.dart';

part 'student_dashboard_binding.dart';
part 'student_dashboard_controller.dart';

class StudentDashboardView extends GetView<StudentDashboardViewController> {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children:  [
            HomeTabView(),
            HomeworkView(),
            AttendanceTabView(),
            ProfileTabView(),
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
                label: "home".tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.clipboardText),
                activeIcon: Icon(PhosphorIconsFill.clipboardText),
                label: "homework".tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.calendarCheck),
                activeIcon: Icon(PhosphorIconsFill.calendarCheck),
                label: "attendance".tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(PhosphorIconsRegular.user),
                activeIcon: Icon(PhosphorIconsFill.user),
                label: "profile".tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
