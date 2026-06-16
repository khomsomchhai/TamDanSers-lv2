part of 'student_dashboard_view.dart';

class StudentDashboardViewBinding extends Bindings {

  @override
  void dependencies() {
      Get.lazyPut(() => StudentDashboardViewController());
      Get.lazyPut(() => HomeTabViewController(),);
      Get.lazyPut(() => HomeworkTabViewController(),);
      Get.lazyPut(() => AttendanceTabViewController(),);
      Get.lazyPut(() => ProfileTabViewController(),);
  }
}