part of 'parent_home_tab_view.dart';

class ParentHomeTabViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentHomeTabViewController());
   }
}