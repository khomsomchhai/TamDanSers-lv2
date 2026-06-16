import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(
      UserController(),
      permanent: true
    );
  }
}