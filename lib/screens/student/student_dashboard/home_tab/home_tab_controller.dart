part of 'home_tab_view.dart';

class HomeTabViewController extends GetxController {

  var userController = Get.find<UserController>();


  String getKhmerDate() {
    DateTime now = DateTime.now();
    List<String> khmerWeekDays = [
      "ថ្ងៃច័ន្ទ",
      "ថ្ងៃអង្គារ",
      "ថ្ងៃពុធ",
      "ថ្ងៃព្រហស្បតិ៍",
      "ថ្ងៃសុក្រ",
      "ថ្ងៃសៅរ៍",
      "ថ្ងៃអាទិត្យ",
    ];
    List<String> khmerMonths = [
      "មករា",
      "កុម្ភៈ",
      "មីនា",
      "មេសា",
      "ឧសភា",
      "មិថុនា",
      "កក្កដា",
      "សីហា",
      "កញ្ញា",
      "តុលា",
      "វិច្ឆិកា",
      "ធ្នូ",
    ];
    String weekDay = khmerWeekDays[now.weekday - 1];
    String month = khmerMonths[now.month - 1];
    return "$weekDay ទី${now.day} ខែ$month ឆ្នាំ${now.year}";
  }

  String getKhmerMonth() {
    DateTime now = DateTime.now();
    List<String> khmerMonths = [
      "មករា",
      "កុម្ភៈ",
      "មីនា",
      "មេសា",
      "ឧសភា",
      "មិថុនា",
      "កក្កដា",
      "សីហា",
      "កញ្ញា",
      "តុលា",
      "វិច្ឆិកា",
      "ធ្នូ",
    ];
    return khmerMonths[now.month - 1];
  }

  String getCurrentDate() {
    if (Get.locale?.languageCode == 'km') {
      return getKhmerDate();
    }

    return DateFormat(
      'EEEE, d MMMM yyyy',
      'en',
    ).format(DateTime.now());
  }

  final notificationController =
      Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());

  @override
  void onInit() {
    super.onInit();
    if(userController.user == null && userController.profile == null){
      userController.getProfile();
    }
    notificationController.loadNotifications();
  }

  Future<void> refreshHome() async {
    await userController.getProfile();
  }

}