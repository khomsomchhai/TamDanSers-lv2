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
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
