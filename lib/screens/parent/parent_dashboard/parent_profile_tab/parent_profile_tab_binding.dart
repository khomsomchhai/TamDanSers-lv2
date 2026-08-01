
import 'package:get/get.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_profile_tab/parent_profile_tab_controller.dart';

class ParentProfileTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentProfileTabViewController());
   }
}