part of 'homework_view.dart';

class HomeworkViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => HomeworkViewController());
   }
}