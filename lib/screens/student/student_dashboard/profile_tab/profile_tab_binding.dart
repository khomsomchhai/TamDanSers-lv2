part of 'profile_tab_view.dart';

class ProfileTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ProfileTabViewController());
   }
}