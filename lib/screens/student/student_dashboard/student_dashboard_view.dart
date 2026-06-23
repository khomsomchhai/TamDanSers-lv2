import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/attendance_tab/attendance_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/home_tab/home_tab_view.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/homework_tab/homework_tab_view.dart';
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
            HomeworkTabView(),
            AttendanceTabView(),
            ProfileTabView()
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: "Homework",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: "Attendance",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}


