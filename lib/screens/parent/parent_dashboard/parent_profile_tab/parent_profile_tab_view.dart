import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/profile_tab/profile_tab_view.dart';

part 'parent_profile_tab_binding.dart';
part 'parent_profile_tab_controller.dart';

class ParentProfileTabView extends GetView<ParentProfileTabViewController> {
  const ParentProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "profile".tr),
      body: Column(
        children: [
          ElevatedButton(onPressed: controller.stuProfileCtrl.logout, child: Text(
            "Logout"
          ))
        ],
      ),
    );
  }
}