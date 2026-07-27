part of 'create_password_parent_view.dart';

class CreatePasswordParentViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => CreatePasswordParentViewController());
   }
}