
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_attendance_tab/parent_attendance_tab_controller.dart';

class ParentAttendanceTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentAttendanceTabViewController());
   }
}