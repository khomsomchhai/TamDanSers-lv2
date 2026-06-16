part of 'homework_tab_view.dart';

class HomeworkTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => HomeworkTabViewController());
   }
}