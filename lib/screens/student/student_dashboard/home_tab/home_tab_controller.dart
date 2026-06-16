part of 'home_tab_view.dart';

class HomeTabViewController extends GetxController {

  var userController = Get.find<UserController>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if(userController.user == null && userController.profile == null){
      userController.getProfile();
    }
  }

}