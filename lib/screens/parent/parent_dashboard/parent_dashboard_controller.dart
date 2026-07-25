part of 'parent_dashboard_view.dart';

class ParentDashboardViewController extends GetxController {
  final userController = Get.find<UserController>();
  final currentIndex = 0.obs;
  final unreadNotifications = 4.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    if (userController.user == null || userController.profile == null) {
      userController.getProfile();
    }
  }

  Future<void> refreshData() async {
    await userController.getProfile();
  }

  void openNotifications() {
    Get.snackbar(
      'notifications'.tr,
      'stay_connected_child'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.white,
      colorText: AppColors.dark,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'good_morning'.tr;
    } else if (hour >= 12 && hour < 17) {
      return 'good_afternoon'.tr;
    } else if (hour >= 17 && hour < 21) {
      return 'good_evening'.tr;
    }
    return 'good_night'.tr;
  }
}
