part of 'student_dashboard_view.dart';

class StudentDashboardViewController extends GetxController {

  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  var box = GetStorage();
  void checkToken(){
    var token = box.read("token") ;

    debugPrint("token: $token ");


    if(token == null){
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    checkToken();
  }

}