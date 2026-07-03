import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';

part 'change_password_screen_binding.dart';
part 'change_password_screen_controller.dart';

class ChangePasswordScreenView extends GetView<ChangePasswordScreenViewController> {
  const ChangePasswordScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Change Password", 
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}