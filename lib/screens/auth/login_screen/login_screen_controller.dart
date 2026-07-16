part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  var idCtrl = TextEditingController();
  var pwdCtrl = TextEditingController();

  var formKey = GlobalKey<FormState>();

  var isRemember = false.obs;
  var isHidePwd = true.obs;
  var isLoading = false.obs;

  // var isKeyboardOpen = false.obs;

  var authService = AuthServices();
  var box = GetStorage();

  // void updateKeyboard(BuildContext context) {
  //   isKeyboardOpen.value = MediaQuery.of(context).viewInsets.bottom > 0;
  // }

  void togglePwd() {
    isHidePwd.value = !isHidePwd.value;
  }

  void login() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.error("Invalid form");
      return;
    }

    try {
      isLoading.value = true;

      var response = await authService.loginService(
        loginId: idCtrl.text,
        password: pwdCtrl.text,
      );

      if (response["access_token"] != null) {
        var token = response["access_token"]?.toString().trim();

        await box.write("token", token);
        await box.write("role", response["role"]);

        try {
          await FirebaseMessaging.instance.requestPermission();

          String? fcmToken =
              await FirebaseMessaging.instance.getToken();

          print("FCM Token: $fcmToken");

          if (fcmToken != null) {
            await authService.saveFcmToken(fcmToken: fcmToken);
            print("FCM token saved successfully");
          }
        } catch (e) {
          print("Save FCM token error: $e");
        }

        if (response["role"] == "student") {
          Get.offAllNamed(AppRoutes.studentDashboard);
        } else if (response["role"] == "parent") {
          Get.offAllNamed(AppRoutes.parentDashboard);
        } else {
          CustomSnackbar.error("Unknown role");
        }
      } else {
        CustomSnackbar.error("Login failed");
      }
    }catch(error){
      CustomSnackbar.error("Login credentials are incorrect");
    }finally{
      isLoading.value = false;
    }
  }
}