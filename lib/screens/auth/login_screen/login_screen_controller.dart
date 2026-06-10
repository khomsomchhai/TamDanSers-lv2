part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  var idCtrl = TextEditingController();
  var pwdCtrl = TextEditingController();

  var formKey = GlobalKey<FormState>();

  var isRemember = false.obs;
  var isHidePwd = true.obs;
  var isLoading = false.obs;

  var isKeyboardOpen = false.obs;

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
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2));
    isLoading.value = false;
    CustomSnackbar.error("Login credentials are incorrect");
  }

  


}