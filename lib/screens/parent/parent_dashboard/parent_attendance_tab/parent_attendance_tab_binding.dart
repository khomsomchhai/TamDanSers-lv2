part of 'parent_attendance_tab_view.dart';

class ParentAttendanceTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentAttendanceTabViewController());
   }
}