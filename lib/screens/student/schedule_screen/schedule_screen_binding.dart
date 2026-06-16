part of 'schedule_screen_view.dart';

class ScheduleScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ScheduleScreenViewController());
   }
}