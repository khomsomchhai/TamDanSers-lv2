part of 'home_tab_view.dart';

class HomeTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => HomeTabViewController());
   }
}