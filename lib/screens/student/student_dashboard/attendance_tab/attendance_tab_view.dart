import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'attendance_tab_binding.dart';
part 'attendance_tab_controller.dart';

class AttendanceTabView extends GetView<AttendanceTabViewController> {
  const AttendanceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance"),),
    );
  }
}