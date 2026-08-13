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
  }

  Future<void> scanAttendance() async {
    final result = await Get.toNamed('/student/attendance-scan');
    if (result == true) {
      if (Get.isRegistered<AttendanceTabViewController>()) {
        await Get.find<AttendanceTabViewController>().fetchAttendance();
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
