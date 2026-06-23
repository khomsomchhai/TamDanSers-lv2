import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';

part 'attendance_tab_binding.dart';
part 'attendance_tab_controller.dart';

class AttendanceTabView extends GetView<AttendanceTabViewController> {
  const AttendanceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "attendance".tr,
        showBackButton: false,
        unreadCount: 2,
      ),
    );
  }
}