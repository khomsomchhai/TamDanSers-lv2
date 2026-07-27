import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_score_card.dart';
import 'package:tamdansers_lv2/core/widgets/score_bar.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';

part 'result_screen_binding.dart';
part 'result_screen_controller.dart';

class ResultScreenView extends GetView<ResultScreenViewController> {
  const ResultScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'result'.tr,showNotification: false,),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  onTap: (index) {
                    controller.selectedSemester.value = index + 1;
                    controller.selectedMonth.value = null;
                    controller.selectFisrtMonth();
                    controller.getRank();
                  },
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.textTheme.bodyLarge?.color?.withOpacity(0.75),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: theme.colorScheme.surface.withOpacity(0.0),
                  tabs: [
                    Tab(child: Text('semester 1'.tr)),
                    Tab(child: Text('semester 2'.tr))
                  ],
                ),
              ),
              Obx(
                () => controller.isLoading.value
                    ? Center(child: skeletonLoading())
                    : Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 80,
                              child: monthList(),
                            ),
                            SizedBox(height: 16),
                            CustomScoreCard(),
                            SizedBox(height: 16),
                            Expanded(
                              child: scoreList(),
                            ),
                          ],
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget skeletonLoading() {
    final theme = Get.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Shimmer.fromColors(
          baseColor: theme.dividerColor.withOpacity(0.25),
          highlightColor: theme.dividerColor.withOpacity(0.10),
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: theme.dividerColor.withOpacity(0.25),
          highlightColor: theme.dividerColor.withOpacity(0.10),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget monthList() {
    final theme = Get.theme;
    return Obx(() {
      if (controller.semesterMonths.isEmpty) {
        return Center(
            child: Text('No months',
                style: AppTextStyles.titleSmall.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.75))));
      }

      return SizedBox(
        height: 60,
        child: Obx(() => ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.semesterMonths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final month = controller.semesterMonths[index];
                return Obx(() {
                  final isSelected = controller.selectedMonth.value == month;

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      controller.selectedMonth.value = month;
                      controller.getRank();
                    },
                    child: Container(
                      width: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (controller.months[month] ?? '').tr,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                });
              },
            )),
      );
    });
  }



  Widget scoreList() {
    final theme = Get.theme;
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: controller.filterScores.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final score = controller.filterScores[index];
                final subject = score.subjectName;
                return SizedBox(
                  height: 150,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: SubjectUi.bgColor(subject),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                SubjectUi.icon(subject),
                                color: SubjectUi.color(subject),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    score.subjectName.tr,
                                    style: AppTextStyles.titleMedium
                                        .copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${'teacher'.tr}: ${score.teacherName}',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.75)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ScoreBar(
                          score: score.score.toDouble(),
                          maxScore: score.maxScore.toDouble(),
                          color: SubjectUi.color(subject),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
