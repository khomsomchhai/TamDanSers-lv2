import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';
import 'package:tamdansers_lv2/screens/student/homework/in_app_pdf_viewer.dart';

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xffE2E8F0),
    this.strokeWidth = 1.2,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap;
  }
}

class HomeworkDetailView extends StatefulWidget {
  final HomeworkItem item;
  final HomeworkViewController controller;

  const HomeworkDetailView({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<HomeworkDetailView> createState() => _HomeworkDetailViewState();
}

class _HomeworkDetailViewState extends State<HomeworkDetailView> {
  final TextEditingController _answerController = TextEditingController();
  final List<XFile> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _keepOldFiles = true;

  bool get _isKhmer => Get.locale?.languageCode == 'km';

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _startEditing() {
    final submission = widget.controller.submissionMap[widget.item.id];

    if (submission == null) {
      Get.snackbar(
        _isKhmer ? 'កំហុស' : 'Error',
        _isKhmer
            ? 'រកមិនឃើញកិច្ចការដែលបានប្រគល់'
            : 'Submission not found',
      );
      return;
    }

    setState(() {
      _answerController.text = submission.answerText ?? '';
      _selectedFiles.clear();
      _keepOldFiles = true;
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _keepOldFiles = true;
      _selectedFiles.clear();
      _answerController.clear();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await _picker.pickMultiImage();

        if (images.isNotEmpty) {
          setState(() => _selectedFiles.addAll(images));
        }
      } else {
        final image = await _picker.pickImage(source: source);

        if (image != null) {
          setState(() => _selectedFiles.add(image));
        }
      }
    } catch (error) {
      Get.snackbar(
        _isKhmer ? 'កំហុស' : 'Error',
        _isKhmer
            ? 'មិនអាចជ្រើសរើសរូបភាពបានទេ៖ $error'
            : 'Failed to pick image: $error',
      );
    }
  }

Future<void> _pickPdf() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
    );

    if (result == null) return;

    final files = result.files
        .where((file) => file.path != null)
        .map((file) => XFile(file.path!))
        .toList();

    if (files.isEmpty) return;

    setState(() {
      _selectedFiles.addAll(files);
    });
  } catch (error) {
    Get.snackbar(
      Get.locale?.languageCode == 'km'
          ? 'កំហុស'
          : 'Error',
      Get.locale?.languageCode == 'km'
          ? 'មិនអាចជ្រើសរើស PDF បានទេ៖ $error'
          : 'Failed to pick PDF: $error',
    );
  }
}
  void _showUploadSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isKhmer ? 'ជ្រើសរើសប្រភពឯកសារ' : 'Select Attachment Source',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                _isKhmer ? 'ថតរូបភាព' : 'Take Photo',
              ),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                _isKhmer ? 'ជ្រើសរើសរូបភាព' : 'Choose Photos',
              ),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Colors.red,
              ),
              title: Text(
                _isKhmer ? 'ឯកសារ PDF' : 'PDF Document',
              ),
              onTap: () {
                Get.back();
                _pickPdf();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: Get.back,
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }

  void _showFullScreenLocalImage(File file) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: Get.back,
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(file),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int submissionId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isKhmer ? 'លុបកិច្ចការ?' : 'Delete submission?',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          _isKhmer
              ? 'តើអ្នកពិតជាចង់លុបកិច្ចការដែលបានប្រគល់នេះមែនទេ?'
              : 'Are you sure you want to delete this submission?',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(_isKhmer ? 'បោះបង់' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              widget.controller.executeDeleteSubmission(
                submissionId: submissionId,
              );
            },
            child: Text(_isKhmer ? 'លុប' : 'Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('khmer')) return AppColors.purple;
    if (name.contains('math')) return AppColors.primary;
    if (name.contains('physic') ||
        name.contains('science') ||
        name.contains('biolog')) {
      return AppColors.success;
    }
    if (name.contains('histor') || name.contains('chemist')) {
      return AppColors.error;
    }
    if (name.contains('geograph') || name.contains('english')) {
      return AppColors.warning;
    }

    return const Color(0xff64748B);
  }

  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('khmer')) return Icons.translate_rounded;
    if (name.contains('math')) return Icons.calculate_outlined;
    if (name.contains('physic') ||
        name.contains('biolog') ||
        name.contains('chemist')) {
      return Icons.science_outlined;
    }
    if (name.contains('histor')) return Icons.menu_book_rounded;
    if (name.contains('geograph')) return Icons.public_rounded;

    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryThemeColor = _getSubjectColor(item.subjectName);

    String statusText;
    Color statusColor;
    Color statusBackground;

    if (item.status == HomeworkStatus.checked) {
      statusText = _isKhmer ? 'ពិនិត្យរួច' : 'Graded';
      statusColor = AppColors.success;
      statusBackground = AppColors.success.withValues(alpha: 0.08);
    } else if (item.status == HomeworkStatus.submitted) {
      statusText = _isKhmer ? 'បានប្រគល់' : 'Submitted';
      statusColor = AppColors.primary;
      statusBackground = AppColors.primary.withValues(alpha: 0.08);
    } else {
      statusText = _isKhmer ? 'មិនទាន់ប្រគល់' : 'Missing';
      statusColor = const Color(0xffD97706);
      statusBackground = const Color(0xffFFFBEB);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Homework Details'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHomeworkInfoCard(
              context: context,
              item: item,
              statusText: statusText,
              statusColor: statusColor,
              statusBackground: statusBackground,
              primaryThemeColor: primaryThemeColor,
            ),
            const SizedBox(height: 24),
            if (item.filePath != null && item.filePath!.isNotEmpty) ...[
              _buildTeacherAttachment(context, item.filePath!),
              const SizedBox(height: 24),
            ],
            if (item.status == HomeworkStatus.none)
              _buildSubmitForm(primaryThemeColor)
            else
              Obx(() {
                final submission = widget.controller.submissionMap[item.id];

                if (submission == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _isKhmer
                            ? 'រកមិនឃើញព័ត៌មានកិច្ចការដែលបានប្រគល់'
                            : 'Submission information not found',
                      ),
                    ),
                  );
                }

                if (_isEditing && item.status == HomeworkStatus.submitted) {
                  return _buildEditForm(
                    primaryThemeColor: primaryThemeColor,
                    submissionId: submission.id,
                  );
                }

                return _buildSubmittedView(
                  context: context,
                  item: item,
                  submission: submission,
                  isDark: isDark,
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkInfoCard({
    required BuildContext context,
    required HomeworkItem item,
    required String statusText,
    required Color statusColor,
    required Color statusBackground,
    required Color primaryThemeColor,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xff1A1A1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight
              ? const Color(0xffE2E8F0)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryThemeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSubjectIcon(item.subjectName),
                      color: primaryThemeColor,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.subjectName.toUpperCase(),
                      style: TextStyle(
                        color: primaryThemeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                color: isLight
                    ? const Color(0xff475569)
                    : const Color(0xff94A3B8),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: Colors.grey,
                size: 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.teacherName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.calendar_month_outlined,
                color: item.status == HomeworkStatus.none
                    ? Colors.orange
                    : Colors.grey,
                size: 15,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.status == HomeworkStatus.none
                      ? (_isKhmer
                          ? 'ផុតកំណត់៖ ${item.date}'
                          : 'Due: ${item.date}')
                      : (_isKhmer
                          ? 'ប្រគល់៖ ${item.date}'
                          : 'Submitted: ${item.date}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.status == HomeworkStatus.none
                        ? Colors.orange
                        : Colors.grey,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherAttachment(BuildContext context, String path) {
    final isPdf = path.toLowerCase().endsWith('.pdf');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isKhmer ? 'ឯកសារភ្ជាប់ពីគ្រូ' : "Teacher's Attachment",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        if (isPdf)
          _buildPdfCard(path)
        else
          GestureDetector(
            onTap: () => _showFullScreenImage(path),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                path,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: const Color(0xffF1F5F9),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPdfCard(String path) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => InAppPdfViewer(
            url: path,
            title: path.split('/').last,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                path.split('/').last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: Colors.grey,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitForm(Color primaryThemeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnswerField(),
        const SizedBox(height: 20),
        _buildUploadArea(primaryThemeColor),
        _buildSelectedFiles(primaryThemeColor),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              final text = _answerController.text.trim();

              if (text.isEmpty && _selectedFiles.isEmpty) {
                Get.snackbar(
                  _isKhmer ? 'កំហុស' : 'Error',
                  _isKhmer
                      ? 'សូមបញ្ចូលចម្លើយ ឬភ្ជាប់ឯកសារ'
                      : 'Please enter an answer or attach a file',
                );
                return;
              }

              widget.controller.executeSubmitHomework(
                context,
                widget.item.id,
                text,
                _selectedFiles,
              );
            },
            child: Text(
              _isKhmer ? 'បញ្ជូនកិច្ចការ' : 'Submit Homework',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm({
    required Color primaryThemeColor,
    required int submissionId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isKhmer
                      ? 'អ្នកកំពុងកែប្រែកិច្ចការដែលបានប្រគល់'
                      : 'You are editing your submission',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildAnswerField(),
        const SizedBox(height: 14),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _keepOldFiles,
          activeColor: AppColors.primary,
          title: Text(
            _isKhmer ? 'រក្សាឯកសារចាស់' : 'Keep existing files',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            _isKhmer
                ? 'បិទ ដើម្បីដកឯកសារចាស់ចេញពីកិច្ចការ'
                : 'Turn off to remove existing files from the submission',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (value) {
            setState(() => _keepOldFiles = value);
          },
        ),
        const SizedBox(height: 10),
        _buildUploadArea(primaryThemeColor),
        _buildSelectedFiles(primaryThemeColor),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _cancelEditing,
                child: Text(_isKhmer ? 'បោះបង់' : 'Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  final text = _answerController.text.trim();

                  if (text.isEmpty &&
                      _selectedFiles.isEmpty &&
                      !_keepOldFiles) {
                    Get.snackbar(
                      _isKhmer ? 'កំហុស' : 'Error',
                      _isKhmer
                          ? 'សូមបញ្ចូលចម្លើយ ឬភ្ជាប់ឯកសារ'
                          : 'Please enter an answer or attach a file',
                    );
                    return;
                  }

                  widget.controller.executeUpdateSubmission(
                    context: context,
                    submissionId: submissionId,
                    answerText: text,
                    selectedFiles: _selectedFiles,
                    keepOldFiles: _keepOldFiles,
                  );
                },
                child: Text(_isKhmer ? 'រក្សាទុក' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isKhmer ? 'មតិឬចំណាំ' : 'Comment or Note',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _answerController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _isKhmer
                ? 'បញ្ចូលព័ត៌មានទៅទីនេះ...'
                : 'Enter information here...',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(Color primaryThemeColor) {
    return GestureDetector(
      onTap: _showUploadSourceSheet,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DashedRectPainter(
                color: const Color(0xffCBD5E1),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: primaryThemeColor,
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  _isKhmer
                      ? 'ភ្ជាប់ឯកសារ (រូបភាព ឬ PDF)'
                      : 'Attach file (Image or PDF)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFiles(Color primaryThemeColor) {
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: _selectedFiles.map((file) {
          final isPdf = file.name.toLowerCase().endsWith('.pdf');

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (!isPdf) {
                      _showFullScreenLocalImage(File(file.path));
                    }
                  },
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    color: isPdf ? Colors.red : primaryThemeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _selectedFiles.remove(file));
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmittedView({
    required BuildContext context,
    required HomeworkItem item,
    required dynamic submission,
    required bool isDark,
  }) {
    final answerText = submission.answerText ?? '';
    final teacherComment = submission.teacherComment;
    final score = submission.score;
    final paths = submission.filePaths.isNotEmpty
        ? List<String>.from(submission.filePaths)
        : (submission.filePath != null && submission.filePath!.isNotEmpty
            ? <String>[submission.filePath!]
            : <String>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.status == HomeworkStatus.submitted) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isKhmer
                        ? 'បានប្រគល់រួច និងកំពុងរង់ចាំគ្រូពិនិត្យ'
                        : 'Submitted and waiting for teacher review',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (item.status == HomeworkStatus.checked) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isKhmer
                        ? 'គ្រូបានពិនិត្យរួច ដូច្នេះមិនអាចកែប្រែ ឬលុបបានទេ។'
                        : 'The teacher has checked this submission. It cannot be edited or deleted.',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (score != null)
            Text(
              _isKhmer ? 'ពិន្ទុ៖ $score' : 'Score: $score',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          const SizedBox(height: 18),
        ],
        Text(
          _isKhmer ? 'ចម្លើយរបស់អ្នក' : 'Your Submission',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1A1A1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffE2E8F0)),
          ),
          child: Text(
            answerText.trim().isEmpty
                ? (_isKhmer ? '(មិនមានអត្ថបទចម្លើយ)' : '(No answer text)')
                : answerText,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: answerText.trim().isEmpty ? Colors.grey : null,
              fontStyle: answerText.trim().isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ),
        if (paths.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            _isKhmer ? 'ឯកសារដែលបានប្រគល់' : 'Submitted Files',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...paths.map((path) {
            final isPdf = path.toLowerCase().endsWith('.pdf');

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: isPdf
                  ? _buildPdfCard(path)
                  : GestureDetector(
                      onTap: () => _showFullScreenImage(path),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          path,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            );
          }),
        ],
        if (teacherComment != null && teacherComment.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isKhmer ? 'មតិយោបល់របស់គ្រូ' : "Teacher's Comment",
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(teacherComment),
              ],
            ),
          ),
        ],
        if (item.status == HomeworkStatus.submitted) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startEditing,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(_isKhmer ? 'កែប្រែ' : 'Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => _showDeleteDialog(submission.id),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(_isKhmer ? 'លុប' : 'Delete'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
