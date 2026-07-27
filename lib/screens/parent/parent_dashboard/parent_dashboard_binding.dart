part of 'parent_dashboard_view.dart';

class ParentDashboardViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ParentDashboardViewController());
    Get.lazyPut(() => ParentHomeTabViewController());
    Get.lazyPut(() => ParentHomeworkTabViewController());
    Get.lazyPut(() => ParentAttendanceTabViewController());
    Get.lazyPut(() => ParentProfileTabViewController());
    Get.lazyPut(() => ProfileTabViewController());
  }
}
