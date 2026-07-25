part of 'parent_homework_tab_view.dart';

class ParentHomeworkTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentHomeworkTabViewController());
   }
}