part of 'parent_dashboard_view.dart';

class ParentDashboardViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentDashboardViewController());
   }
}