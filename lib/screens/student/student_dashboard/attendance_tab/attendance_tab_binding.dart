part of 'attendance_tab_view.dart';

class AttendanceTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => AttendanceTabViewController());
   }
}