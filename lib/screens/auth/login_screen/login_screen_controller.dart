part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  var idCtrl = TextEditingController();
  var pwdCtrl = TextEditingController();

  var formKey = GlobalKey<FormState>();

  var isRemember = false.obs;
  var isHidePwd = true.obs;
  var isLoading = false.obs;

  var isKeyboardOpen = false.obs;

  var authService = AuthServices();
  var box = GetStorage();

  void updateKeyboard(BuildContext context) {
    isKeyboardOpen.value = MediaQuery.of(context).viewInsets.bottom > 0;
  }

  void togglePwd(){
    isHidePwd.value = !isHidePwd.value;
  }

  void login() async{
    if(!formKey.currentState!.validate()){
      CustomSnackbar.error("Invalid form");
      return;
    }
    try{
      isLoading.value = true;
      var response = await authService.loginService(
        loginId: idCtrl.text, 
        password: pwdCtrl.text
      );
      if(response["access_token"] != null){
        await box.write(
          "token",
          response["access_token"],
        );
        await box.write(
          "role",
          response["role"],
        );
        CustomSnackbar.success("Login successful");
        if(response["role"] == "student"){
          Get.offAllNamed(
            AppRoutes.studentDashboard,
          );
        }else if(response["role"] == "parent"){
          Get.offAllNamed(
            AppRoutes.parentDashboard,
          );
        }else{
          CustomSnackbar.error("Unknown role");
        }
      }else{
        CustomSnackbar.error("Login failed");
      }

      isLoading.value = false;
    }catch(error){
      CustomSnackbar.error("Login credentials are incorrect");
      isLoading.value = false;
    }
  }

  


}