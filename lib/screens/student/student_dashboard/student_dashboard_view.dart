import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          children: const [
            HomeTabView(),
            HomeworkView(),
            AttendanceTabView(),
            ProfileTabView()
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "home".tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: "homework".tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: "attendance".tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "profile".tr,
            ),
          ],
        ),
      ),
    );
  }
}


