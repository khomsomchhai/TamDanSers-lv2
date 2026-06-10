import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  danger,
  success,
  white,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = AppNumbers.radiusMedium,
  });

  Color getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;

      case ButtonVariant.secondary:
        return AppColors.secondary;

      case ButtonVariant.danger:
        return AppColors.error;

      case ButtonVariant.success:
        return AppColors.success;

      case ButtonVariant.white:
        return AppColors.white;

      case ButtonVariant.outlined:
        return Colors.transparent;
    }
  }

  Color getTextColor() {
    switch (variant) {
      case ButtonVariant.white:
        return AppColors.dark;

      default:
        return AppColors.white;
    }
  }

  BorderSide? getBorder() {
    switch (variant) {
      case ButtonVariant.outlined:
        return const BorderSide(
          color: Colors.white,
          width: 1.2,
        );

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        shadowColor: AppColors.transparent,
        elevation: 0,
        backgroundColor: getBackgroundColor(),
        foregroundColor: getTextColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: getBorder() ?? BorderSide.none,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: getTextColor(),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 8),
                ],

                Text(
                  text,
                  style: Get.textTheme.titleSmall!.copyWith(color: getTextColor())
                ),

                if (suffixIcon != null) ...[
                  const SizedBox(width: 8),
                  suffixIcon!,
                ],
              ],
            ),
    );
  }
}