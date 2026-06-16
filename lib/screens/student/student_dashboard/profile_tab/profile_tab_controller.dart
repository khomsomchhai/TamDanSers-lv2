part of 'profile_tab_view.dart';

class ProfileTabViewController extends GetxController {
  var userController = Get.find<UserController>();

  var box = GetStorage();

  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text("Logout"),
        content: Text(
          "Are you sure?"
        ),
        actions: [
          ElevatedButton(onPressed: () {
            Get.back();
          }, child: Text("No")),
          ElevatedButton(onPressed: () {
            box.remove("token");
            Get.offAllNamed(AppRoutes.loginScreen);
          }, child: Text("yes"))
        ],
      )
    );
    
  }

}