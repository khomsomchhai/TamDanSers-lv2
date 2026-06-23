import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';

part 'profile_tab_binding.dart';
part 'profile_tab_controller.dart';

class ProfileTabView extends GetView<ProfileTabViewController> {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "profile".tr,
        showBackButton: false,
        unreadCount: 2,
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: () {
            controller.logout();
          }, child: Text("Logout"))
        ],
      ),
    );
  }
}