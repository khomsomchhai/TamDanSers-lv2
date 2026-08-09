part of 'attendance_scan_view.dart';

class AttendanceScanBinding
    extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<
        AttendanceScanController>(
      () =>
          AttendanceScanController(),
    );
  }
}