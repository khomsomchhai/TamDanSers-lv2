part of 'change_password_screen_view.dart';

class ChangePasswordScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ChangePasswordScreenViewController());
   }
}