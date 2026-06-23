import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';

class CustomFunctionCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color iconBackColor;
  const CustomFunctionCard({
    super.key, 
    required this.title, 
    required this.icon, 
    required this.iconBackColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(AppNumbers.radiusMedium)
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBackColor,
                shape: BoxShape.circle
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: icon
              ),
            ),
            SizedBox(height: 4,),
            Text(
              title,
              style: Get.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}