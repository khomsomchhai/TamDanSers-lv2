part of 'parent_profile_tab_view.dart';

class ParentProfileTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentProfileTabViewController());
   }
}