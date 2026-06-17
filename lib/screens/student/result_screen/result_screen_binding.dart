part of 'result_screen_view.dart';

class ResultScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ResultScreenViewController());
   }
}