part of 'student_dashboard_view.dart';

class StudentDashboardViewController extends GetxController
    with WidgetsBindingObserver {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;

    if (index == 0 && Get.isRegistered<HomeTabViewController>()) {
      Get.find<HomeTabViewController>().refreshHome();
    }

    if (index == 1) {
      if (Get.isRegistered<HomeworkViewController>()) {
        Get.find<HomeworkViewController>().fetchHomework();
      }
    }

    if (index == 2 && Get.isRegistered<AttendanceTabViewController>()) {
      Get.find<AttendanceTabViewController>().fetchAttendance();
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshVisibleTab();
    }
  }

  void _refreshVisibleTab() {
    if (currentIndex.value == 0 && Get.isRegistered<HomeTabViewController>()) {
      Get.find<HomeTabViewController>().refreshHome();
    }

    if (currentIndex.value == 2 &&
        Get.isRegistered<AttendanceTabViewController>()) {
      Get.find<AttendanceTabViewController>().fetchAttendance();
    }
  }
}
