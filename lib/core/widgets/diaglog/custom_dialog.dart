import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';

class CustomDialog {
  static Future<void> showError({
    String title = "Error",
    required String message,
  }) async {
    await Get.dialog(
      _DialogTemplate(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        title: title,
        message: message,
      ),
    );
  }

  static Future<void> showSuccess({
    String title = "Success",
    required String message,
  }) async {
    await Get.dialog(
      _DialogTemplate(
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.success,
        title: title,
        message: message,
      ),
    );
  }

  static Future<void> showWarning({
    String title = "Warning",
    required String message,
  }) async {
    await Get.dialog(
      _DialogTemplate(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warning,
        title: title,
        message: message,
      ),
    );
  }

  static Future<bool> showNetworkRetry({
    String? title,
    required String message,
    String? retryText,
    bool barrierDismissible = false,
  }) async {
    return await Get.dialog<bool>(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_outlined,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title ?? "network_error".tr,
                    style: Get.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        retryText ?? "retry".tr,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: barrierDismissible,
        ) ??
        false;
  }

  static Future<void> showConfirm({
    String title = "Confirmation",
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppNumbers.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 60,
              ),

              const SizedBox(height: 16),

              Text(
                title,
                style: Get.textTheme.titleSmall
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      child: Text(cancelText, style: Get.textTheme.bodyMedium,),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      child: Text(confirmText, style: Get.textTheme.bodyMedium,),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showLoading({
    String message = "Please wait...",
  }) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),

                const SizedBox(height: 20),

                Text(
                  message,
                  style: Get.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

class _DialogTemplate extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  const _DialogTemplate({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 60,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: Get.textTheme.titleSmall
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Get.back,
                child: Text("Close", style: Get.textTheme.bodyMedium,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}