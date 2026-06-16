part of 'ask_permission_screen_view.dart';

class AskPermissionScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => AskPermissionScreenViewController());
   }
}