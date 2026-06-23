import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String title;
  final bool showBackButton;
  final bool showNotification;
  final int unreadCount;
  final VoidCallback? onBack;
  final VoidCallback? onNotification;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showNotification = true,
    this.unreadCount = 0,
    this.onBack,
    this.onNotification,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,

      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: onBack ?? () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.lightGrey,
                      width: 1
                    )
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          : null,

      title: Text(
        title,
        style: Get.textTheme.titleMedium,
      ),

      actions: [
        if(showNotification)
      
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: onNotification,
                  icon: const Icon(Icons.notifications, color: AppColors.dark,),
                ),

                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadCount > 99 ? "99+" : unreadCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          ),
      ],
    );
  }
}