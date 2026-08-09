import 'package:get/get.dart';
import 'view_student_result_detail_controller.dart';

class ViewStudentResultDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewStudentResultDetailController>(
      () => ViewStudentResultDetailController(),
    );
  }
}
