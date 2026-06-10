import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isPwd;
  final bool isHide;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isMultiline;
  final FocusNode? nameFoucs;
  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPwd = false,
    required this.controller,
    this.validator,
    this.isHide = false,
    this.isMultiline = false,
    this.nameFoucs
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: nameFoucs,
      controller: controller,
      validator: validator,
      obscureText: isPwd && isHide,
      minLines: isMultiline ? 5 : 1,
      maxLines: isMultiline ? 10 : 1,
      cursorColor: AppColors.dark,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Get.textTheme.bodyMedium!.copyWith(color: AppColors.hintColor),
        prefixIcon: prefixIcon,
        suffixIcon: isPwd ? suffixIcon : null,
        errorStyle: Get.textTheme.bodyMedium!.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppNumbers.radiusMedium)
        ),
        filled: true,
        fillColor: AppColors.white
      ),
      
    );
  }
}