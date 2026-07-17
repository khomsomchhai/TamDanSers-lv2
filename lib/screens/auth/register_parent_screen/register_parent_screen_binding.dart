part of 'register_parent_screen_view.dart';

class RegisterParentScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => RegisterParentScreenViewController());
   }
}