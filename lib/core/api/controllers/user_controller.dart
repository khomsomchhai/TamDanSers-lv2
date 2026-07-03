import 'dart:io';

import 'package:get/state_manager.dart';
import 'package:tamdansers_lv2/core/api/services/user_services.dart';
import 'package:tamdansers_lv2/data/model/profile_model.dart';
import 'package:tamdansers_lv2/data/model/user_model.dart';

class UserController extends GetxController {
  var userService = UserServices();

  UserModel? user;
  ProfileModel? profile;

  var isLoading = false.obs;

  Future<void> getProfile() async {
    isLoading.value = true;
    try {
      var response = await userService.fechProfile();
      user = UserModel.fromJson(response["user"]);
      profile = ProfileModel.fromJson(response["profile"]);
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