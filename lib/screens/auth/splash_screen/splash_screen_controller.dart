part of 'splash_screen_view.dart';

class SplashScreenViewController extends GetxController {
  var box = GetStorage();
  RxnString token = RxnString();
  RxnString role = RxnString();

  void getToken(){
    token.value = box.read("token");
    role.value = box.read("role");
    debugPrint("My Token : ${token.value}");
    debugPrint("My Role : ${role.value}");
  }

  void navigation() async{
    await Future.delayed(Duration(seconds: 2));
    getToken();
    if(token.value == null){
      Get.offNamed(AppRoutes.loginScreen);
      return;
    }

    if(role.value == "student"){
      Get.offNamed(AppRoutes.studentDashboard);
    } else if(role.value == "parent"){
      Get.offNamed(AppRoutes.parentDashboard);
    } else {
      Get.offNamed(AppRoutes.loginScreen);
    }
  }

}