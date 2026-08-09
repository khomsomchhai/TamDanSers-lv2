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
                      color: Colors.black.withOpacity(0.06),
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
                      'មិនមានលទ្ធផលសិក្សា',
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
                      'អូសចុះក្រោមដើម្បីផ្ទុកឡើងវិញ',
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
                // _buildSummaryCard(),
                // _buildSummaryCardsRow(),
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
  // BLUE 3-CARD SUMMARY ROW
  // ============================================================

  Widget _buildSummaryCardsRow() {
    final double totalScore = controller.totalScore.value;
    final int rank = controller.rank.value;
    final double average = controller.average.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B52C7), // Blue outer background container
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // ----------------------------------------------------
          // 1. TOTAL SCORE (ពិន្ទុសរុប)
          // ----------------------------------------------------
          Expanded(
            child: _buildSummaryCardItem(
              icon: Icons.star_rounded,
              title: 'ពិន្ទុសរុប',
              value: controller.formatNumber(totalScore),
            ),
          ),

          const SizedBox(width: 8),

          // ----------------------------------------------------
          // 2. RANK (ចំណាត់ថ្នាក់)
          // ----------------------------------------------------
          Expanded(
            child: _buildSummaryCardItem(
              icon: Icons.emoji_events_rounded,
              title: 'ចំណាត់ថ្នាក់',
              value: rank > 0 ? '$rank' : '-',
            ),
          ),

          const SizedBox(width: 8),

          // ----------------------------------------------------
          // 3. AVERAGE (មធ្យមភាគ)
          // ----------------------------------------------------
          Expanded(
            child: _buildSummaryCardItem(
              icon: Icons.bar_chart_rounded,
              title: 'មធ្យមភាគ',
              value: controller.formatNumber(average),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF506CEB), // Inner card blue
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    final double totalScore = controller.totalScore.value;

    final double totalMax = controller.totalMaxScore.value;

    final double percent =
        totalMax > 0 ? (totalScore / totalMax).clamp(0.0, 1.0) : 0.0;

    final double percentValue = percent * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

          const Text(
            'សង្ខេបលទ្ធផល',
            style: TextStyle(
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
                  title: 'ពិន្ទុសរុប',
                  value: '${controller.formatNumber(totalScore)} / '
                      '${controller.formatNumber(totalMax)}',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.percent,
                  title: 'ភាគរយ',
                  value: '${percentValue.toStringAsFixed(1)}%',
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
                  title: 'មុខវិជ្ជា',
                  value: '${controller.subjectResults.length}',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'ចំណាត់ថ្នាក់',
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
              value: percent,
              minHeight: 9,
              backgroundColor: Colors.grey.shade200,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '${percentValue.toStringAsFixed(1)}%',
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
            color: Colors.black.withOpacity(0.04),
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
                  color: subject.color.withOpacity(
                    0.12,
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
                      'មុខវិជ្ជា #${subject.subjectId}',
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
                'ពិន្ទុ',
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
            _getScoreRemark(
              percentValue,
            ),
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

  String _getScoreRemark(
    double percentage,
  ) {
    if (percentage >= 90) {
      return 'ល្អឥតខ្ចោះ';
    }

    if (percentage >= 80) {
      return 'ល្អណាស់';
    }

    if (percentage >= 70) {
      return 'ល្អ';
    }

    if (percentage >= 60) {
      return 'មធ្យមល្អ';
    }

    if (percentage >= 50) {
      return 'មធ្យម';
    }

    return 'ត្រូវការកែលម្អ';
  }
}
