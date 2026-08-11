import 'dart:io';

import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/core/api/services/user_services.dart';
import 'package:tamdansers_lv2/data/model/profile_model.dart';
import 'package:tamdansers_lv2/data/model/user_model.dart';

class UserController extends GetxController {
  var userService = UserServices();

  UserModel? user;
  ProfileModel? profile;

  var isLoading = false.obs;
  
  void clearUser() {
    user = null;
    profile = null;
    update();
  }
  Future<void> getProfile() async {
    isLoading.value = true;
    try {
      final response = await userService.fechProfile();
      final data = Map<String, dynamic>.from(response);

      final userJson = data['user'];
      final profileJson = data['profile'];

      user = UserModel.fromJson(
        userJson is Map ? Map<String, dynamic>.from(userJson) : null,
      );
      profile = profileJson is Map
          ? ProfileModel.fromJson(Map<String, dynamic>.from(profileJson))
          : null;

      if (profile != null) {
        GetStorage().write('student_id', profile!.id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadAvatar(File file) async {
    isLoading.value = true;
    try {
      await userService.uploadAvatar(file);
      await getProfile();
    } finally {
      isLoading.value = false;
    }
  }
}