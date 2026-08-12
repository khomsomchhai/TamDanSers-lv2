part of 'student_dashboard_view.dart';

class StudentDashboardViewController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;

    if (index == 1) {
      if (Get.isRegistered<HomeworkViewController>()) {
        Get.find<HomeworkViewController>().fetchHomework();
      }
    }

    if (index == 2) {
      if (Get.isRegistered<AttendanceTabViewController>()) {
        Get.find<AttendanceTabViewController>().fetchAttendance();
      }
    }

    if (index == 0) {
      if (Get.isRegistered<HomeTabViewController>()) {
        Get.find<HomeTabViewController>().refreshHome();
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
