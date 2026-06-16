import 'package:flutter/widgets.dart';
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

  var box = GetStorage();

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      var response = await userService.fechProfile();
      user = UserModel.fromJson(response["user"]);
      profile = ProfileModel.fromJson(response["profile"]);
    } finally {
      isLoading.value = false;
    }
  }

  void checkToken(){
    var token = box.read("token") ;

    debugPrint("token: $token ");


    if(token != null){
      getProfile();
    }
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    checkToken();
  }
}