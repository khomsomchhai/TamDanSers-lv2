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
        var token = response["access_token"]?.toString().trim();
        await box.write(
          "token",
          token,
        );
        await box.write(
          "role",
          response["role"],
        );
        
        // Fetch profile immediately after login success
        await Get.find<UserController>().getProfile();

        // CustomSnackbar.success("Login successful");
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        CustomSnackbar.error("Connection timed out. Please check your internet connection.");
      } else if (e.type == DioExceptionType.unknown) {
        var errorText = e.error?.toString().toLowerCase() ?? "";
        if (errorText.contains("socketexception") || errorText.contains("connection") || errorText.contains("network")) {
          CustomSnackbar.error("Unable to connect. Please check your internet connection.");
        } else {
          CustomSnackbar.error(e.message ?? "Login failed");
        }
      } else if (e.response?.statusCode == 401) {
        CustomSnackbar.error("Login credentials are incorrect");
      } else {
        CustomSnackbar.error(e.message ?? "Login failed");
      }
    } catch (error) {
      var message = error.toString().replaceFirst('Exception: ', '');
      if (message.isEmpty || message == 'Failed') {
        message = 'Login failed';
      }
      CustomSnackbar.error(message);
    } finally {
      isLoading.value = false;
    }
  }

  


}