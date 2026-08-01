part of 'parent_permission_view.dart';

class ParentPermissionBinding
    extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<
        ParentPermissionController>(
      () =>
          ParentPermissionController(),
    );
  }
}