part of 'parent_home_tab_view.dart';

class ParentHomeTabViewController extends GetxController {
  final userController = Get.find<UserController>();
  final box = GetStorage();

  final isLoading = false.obs;
  final students = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadStudents();

    if (userController.user == null && userController.profile == null) {
      userController.getProfile();
    }
  }

  void loadStudents() {
    final data = box.read("students");

    if (data is List) {
      students.assignAll(
        data.map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
    }
  }

  String get childName {
    if (students.isEmpty) {
      return "dont_have_child";
    }

    return students.first["student_name"]?.toString() ??
        "dont_have_child";
  }
  String get childCode {
    if (students.isEmpty) {
      return "dont_have_child";
    }

    return students.first["student_code"]?.toString() ??
        "dont_have_child";
  }
}