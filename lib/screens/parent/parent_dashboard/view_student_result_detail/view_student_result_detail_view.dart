import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/data/model/SubjectResultDetailModel.dart';
import 'view_student_result_detail_controller.dart';

class ViewStudentResultDetailView extends StatefulWidget {
  const ViewStudentResultDetailView({
    super.key,
  });

  @override
  State<ViewStudentResultDetailView> createState() =>
      _ViewStudentResultDetailViewState();
}

class _ViewStudentResultDetailViewState
    extends State<ViewStudentResultDetailView> {
  late final ViewStudentResultDetailController controller;

  @override
  void initState() {
    super.initState();

    // ========================================================
    // IMPORTANT
    // ========================================================
    //
    // Controller should be created by GetX Binding.
    //
    // We DO NOT use:
    //
    // Get.put(ViewStudentResultDetailController())
    //
    // here.
    //
    // ========================================================

    controller = Get.find<ViewStudentResultDetailController>();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF7F8FA), // Light background
        centerTitle: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          controller.semesterTitle.value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: Obx(
        () {
          // ==================================================
          // LOADING
          // ==================================================

          if (controller.isLoading.value && controller.subjectResults.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final isKm = Get.locale?.languageCode == 'km';

          // ==================================================
          // ERROR / EMPTY
          // ==================================================

          if (controller.subjectResults.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.fetchDetailedResultsFromApi,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(
                          context,
                        ).size.height *
                        0.25,
                  ),
                  Icon(
                    Icons.school_outlined,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Text(
                      isKm ? 'មិនមានលទ្ធផលសិក្សា' : 'No Academic Results',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Center(
                    child: Text(
                      isKm
                          ? 'អូសចុះក្រោមដើម្បីផ្ទុកឡើងវិញ'
                          : 'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // RESULTS
          // ==================================================

          return RefreshIndicator(
            onRefresh: controller.fetchDetailedResultsFromApi,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(),
                const SizedBox(
                  height: 16,
                ),
                ...List.generate(
                  controller.subjectResults.length,
                  (index) {
                    final SubjectResultDetailModel subject =
                        controller.subjectResults[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _buildSubjectCard(
                        subject,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    final bool isKm = Get.locale?.languageCode == 'km';

    final double totalScore = controller.totalScore.value;
    final double totalMax = controller.totalMaxScore.value;
    final double avg = controller.average.value;
    final double pct = controller.percentage.value;

    // Percentage for the progress bar (totalScore / totalMax * 100)
    final double displayPct =
        totalMax > 0 ? (totalScore / totalMax * 100) : (pct > 0 ? pct : avg);

    // Real average from the API — used for the Average tile.
    // Falls back to displayPct only when the API returns nothing.
    final double displayAvg = avg > 0 ? avg : displayPct;

    final double progressValue = (displayPct / 100.0).clamp(0.0, 1.0);

    final String scoreDisplay = totalMax > 0
        ? '${controller.formatNumber(totalScore)} / ${controller.formatNumber(totalMax)}'
        : (totalScore > 0
            ? controller.formatNumber(totalScore)
            : '${displayPct.toStringAsFixed(1)}%');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // TITLE
          // ==================================================

          Text(
            isKm ? 'សង្ខេបលទ្ធផល' : 'Result Summary',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // SCORE
          // ==================================================

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.assessment_outlined,
                  title: isKm ? 'ពិន្ទុសរុប' : 'Total Score',
                  value: scoreDisplay,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.show_chart,
                  title: isKm ? 'មធ្យមភាគ' : 'Average',
                  value: displayAvg.toStringAsFixed(1),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.school_outlined,
                  title: isKm ? 'មុខវិជ្ជា' : 'Subjects',
                  value: '${controller.subjectResults.length}',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.emoji_events_outlined,
                  title: isKm ? 'ចំណាត់ថ្នាក់' : 'Rank',
                  value: controller.rank.value > 0
                      ? '${controller.rank.value}'
                      : '-',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ==================================================
          // PROGRESS
          // ==================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 9,
              backgroundColor: Colors.grey.shade200,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '${displayPct.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 25,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBJECT CARD
  // ============================================================

  Widget _buildSubjectCard(
    SubjectResultDetailModel subject,
  ) {
    final bool isKm = Get.locale?.languageCode == 'km';

    final double percent = subject.percentage;

    final double percentValue = subject.percentageValue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // SUBJECT HEADER
          // ==================================================

          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: subject.color.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  subject.icon,
                  color: subject.color,
                  size: 27,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isKm
                          ? 'មុខវិជ្ជា #${subject.subjectId}'
                          : 'Subject #${subject.subjectId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '${percentValue.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: subject.color,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // SCORE
          // ==================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isKm ? 'ពិន្ទុ' : 'Score',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${controller.formatNumber(subject.score)} / '
                '${controller.formatNumber(subject.maxScore)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 9,
          ),

          // ==================================================
          // PROGRESS
          // ==================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 9,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                subject.color,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            _getScoreRemark(percentValue, isKm),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subject.color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE REMARK
  // ============================================================

  String _getScoreRemark(double percentage, bool isKm) {
    if (percentage >= 90) {
      return isKm ? 'ល្អឥតខ្ចោះ' : 'Excellent';
    }

    if (percentage >= 80) {
      return isKm ? 'ល្អណាស់' : 'Very Good';
    }

    if (percentage >= 70) {
      return isKm ? 'ល្អ' : 'Good';
    }

    if (percentage >= 60) {
      return isKm ? 'មធ្យមល្អ' : 'Above Average';
    }

    if (percentage >= 50) {
      return isKm ? 'មធ្យម' : 'Average';
    }

    return isKm ? 'ត្រូវការកែលម្អ' : 'Needs Improvement';
  }
}
