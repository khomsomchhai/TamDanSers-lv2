import 'package:flutter/material.dart';
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
  final TextInputType? keyboardType;
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
    this.nameFoucs,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      focusNode: nameFoucs,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: isPwd && isHide,
      minLines: isMultiline ? 5 : 1,
      maxLines: isMultiline ? 10 : 1,
      cursorColor:
          theme.textSelectionTheme.cursorColor ?? theme.colorScheme.onSurface,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelStyle: theme.textTheme.bodyLarge,
        hintText: hintText,
        hintStyle: theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor),
        prefixIcon: prefixIcon,
        suffixIcon: isPwd ? suffixIcon : null,
        errorStyle:
            theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.error),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppNumbers.spacingMedium,
          vertical: AppNumbers.spacingMedium,
        ),
      ),
    );
  }
}
