import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamdansers_lv2/screens/student/homework/in_app_pdf_viewer.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_view.dart';

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
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    path.addRRect(rrect);

    final Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + gap),
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
  final _answerController = TextEditingController();
  final List<XFile> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(images);
          });
        }
      } else {
       final XFile? image = await _picker.pickImage(
        source: source,
      );
        if (image != null) {
          setState(() {
            _selectedFiles.add(image);
          });
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          _selectedFiles.addAll(
            result.files
                .where((f) => f.path != null)
                .map((f) => XFile(f.path!)),
          );
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick PDF: $e");
    }
  }

  void _showUploadSourceSheet() {
    final isKm = Get.locale?.languageCode == 'km';
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKm ? 'ជ្រើសរើសប្រភពឯកសារ' : 'Select Attachment Source',
              style: Get.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title:
                  Text(isKm ? 'ថតរូបភាព (ម៉ាស៊ីនថត)' : 'Take Photo (Camera)'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title:
                  Text(isKm ? 'រូបភាពពីវិចិត្រសាល' : 'Choose Photo (Gallery)'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
              title: Text(isKm ? 'ឯកសារ PDF' : 'PDF Document'),
              onTap: () {
                Get.back();
                _pickPdf();
              },
            ),
            const SizedBox(height: 10),
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
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Get.back(),
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
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Get.back(),
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

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
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
    if (name.contains('histor') || name.contains('chemist'))
      return AppColors.error;
    if (name.contains('geograph') || name.contains('english'))
      return AppColors.warning;
    return const Color(0xff64748B); // Neat grey fallback
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
    final isKm = Get.locale?.languageCode == 'km';
    final item = widget.item;

    String statusText = '';
    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey;

    if (item.status == HomeworkStatus.checked) {
      statusText = isKm ? 'ពិនិត្យរួច' : 'Graded';
      statusColor = AppColors.success;
      statusBg = AppColors.success.withOpacity(0.08);
    } else if (item.status == HomeworkStatus.submitted) {
      statusText = isKm ? 'បានប្រគល់' : 'Submitted';
      statusColor = AppColors.primary;
      statusBg = AppColors.primary.withOpacity(0.08);
    } else {
      statusText = isKm ? 'មិនទាន់ប្រគល់' : 'Missing';
      statusColor = const Color(0xffD97706);
      statusBg = const Color(0xffFFFBEB);
    }

    final primaryThemeColor = _getSubjectColor(item.subjectName);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xffF8FAFC)
          : const Color(0xff0F0F12),
      appBar: AppBar(
        toolbarHeight: 64,
        title: Text(
          isKm ? 'ព័ត៌មានកិច្ចការ' : 'Homework Details',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xffF8FAFC)
            : const Color(0xff0F0F12),
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.dark
            : AppColors.white,
        leadingWidth: 70,
        leading: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.white
                    : Colors.grey[900],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.dark
                    : AppColors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean & Modern Homework Info Card
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xff1A1A1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xffE2E8F0)
                      : Colors.white.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Subject tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryThemeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getSubjectIcon(item.subjectName),
                                color: primaryThemeColor, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              item.subjectName.toUpperCase(),
                              style: TextStyle(
                                color: primaryThemeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
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
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xff475569)
                            : const Color(0xff94A3B8),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xffE2E8F0)),
                  const SizedBox(height: 14),
                  // Metadata row
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          color: Colors.grey, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        item.teacherName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_month_outlined,
                          color: item.status == HomeworkStatus.none
                              ? Colors.orange
                              : Colors.grey,
                          size: 15),
                      const SizedBox(width: 6),
                      Text(
                        (item.status == HomeworkStatus.submitted ||
                                item.status == HomeworkStatus.checked)
                            ? (isKm
                                ? 'ប្រគល់៖ ${item.date}'
                                : 'Submitted: ${item.date}')
                            : (isKm
                                ? 'ផុតកំណត់៖ ${item.date}'
                                : 'Due: ${item.date}'),
                        style: TextStyle(
                          color: item.status == HomeworkStatus.none
                              ? Colors.orange
                              : Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Teacher Attachment section
            if (item.filePath != null && item.filePath!.isNotEmpty) ...[
              Text(
                isKm ? 'ឯកសារភ្ជាប់ពីគ្រូ' : 'Teacher\'s Attachment',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xff334155)
                      : const Color(0xffCBD5E1),
                ),
              ),
              const SizedBox(height: 10),
              Builder(builder: (context) {
                final teacherFile = item.filePath!;
                final isTeacherPdf = teacherFile.toLowerCase().endsWith('.pdf');
                if (isTeacherPdf) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => InAppPdfViewer(
                            url: teacherFile,
                            title: teacherFile.split('/').last,
                          ));
                    },
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        color: Colors.red.withOpacity(0.04),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.picture_as_pdf_outlined,
                                color: Colors.red, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacherFile.split('/').last,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isKm ? 'ចុចដើម្បីបើក PDF' : 'Tap to open PDF',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.open_in_new,
                              color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => _showFullScreenImage(teacherFile),
                  child: Container(
                    width: double.maxFinite,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xffE2E8F0)
                            : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Image.network(
                            teacherFile,
                            width: double.maxFinite,
                            height: 160,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 160,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color(0xffF1F5F9)
                                    : const Color(0xff1C1C1F),
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 160,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xffF1F5F9)
                                  : const Color(0xff1C1C1F),
                              child: const Center(
                                  child: Icon(Icons.broken_image_rounded,
                                      color: Colors.grey, size: 28)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.zoom_in_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // 3. User Input / Submission Area
            if (item.status == HomeworkStatus.none) ...[
              // Text Area for answer
              Text(
                isKm ? 'មតិឬចំណាំ' : 'Comment or Note',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xff334155)
                      : const Color(0xffCBD5E1),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _answerController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: isKm
                      ? 'បញ្ចូលព័ត៌មានទៅទីនេះ...'
                      : 'Enter information here...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : const Color(0xff1A1A1E),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xffE2E8F0)
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xffE2E8F0)
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: primaryThemeColor, width: 1.2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              // Dotted Attachment Area - Cleaned up to look like Google Classroom / Duolingo style
              GestureDetector(
                onTap: _showUploadSourceSheet,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DashedRectPainter(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xffCBD5E1)
                                  : Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color(0xff1A1A1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: primaryThemeColor,
                            size: 28,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isKm
                                ? 'ភ្ជាប់ឯកសារ (រូបភាព ឬ PDF)'
                                : 'Attach file (Image or PDF)',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isKm ? 'ទំហំអតិបរមា ៥MB' : 'Max file size 5MB',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Attached list items
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  children: _selectedFiles.map((file) {
                    final isPdf = file.name.toLowerCase().endsWith('.pdf');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (!isPdf) {
                            _showFullScreenLocalImage(File(file.path));
                          } else {
                            Get.snackbar(
                              isKm ? 'ព័ត៌មាន' : 'Information',
                              isKm
                                  ? 'មិនអាចបង្ហាញឯកសារ PDF ជាទម្រង់រូបភាពបានឡើយ'
                                  : 'PDF files cannot be previewed as images',
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xffF1F5F9)
                                    : const Color(0xff25252A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPdf ? Icons.picture_as_pdf : Icons.image,
                                color: isPdf ? Colors.red : primaryThemeColor,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.grey, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _selectedFiles.remove(file);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 28),

              // Footer Submit button
              SizedBox(
                width: double.maxFinite,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final text = _answerController.text.trim();
                    if (text.isEmpty && _selectedFiles.isEmpty) {
                      Get.snackbar(
                        isKm ? 'កំហុស' : 'Error',
                        isKm
                            ? 'សូមបញ្ចូលចម្លើយ ឬភ្ជាប់រូបភាពមុនពេលប្រគល់!'
                            : 'Please enter an answer or attach an image first!',
                        backgroundColor: AppColors.error.withOpacity(0.08),
                        colorText: AppColors.error,
                      );
                      return;
                    }
                    widget.controller.executeSubmitHomework(
                        context, item.id, text, _selectedFiles);
                  },
                  child: Text(
                    isKm ? 'បញ្ជូនកិច្ចការ' : 'Submit Homework',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Submitted / Graded display view
              Obx(() {
                final sub = widget.controller.submissionMap[item.id];
                final answerText = sub?.answerText ?? '';
                final filePath = sub?.filePath;
                final score = sub?.score;
                final teacherComment = sub?.teacherComment;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Sleek Evaluation and Score Section (If Graded)
                    if (item.status == HomeworkStatus.checked &&
                        score != null) ...[
                      Container(
                        width: double.maxFinite,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : const Color(0xff1A1A1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$score',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKm
                                        ? 'ពិនិត្យរួចរាល់'
                                        : 'Graded Successfully',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isKm
                                        ? 'ទទួលបានពិន្ទុ $score លើ ១០'
                                        : 'Score: $score out of 10',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (item.status == HomeworkStatus.submitted) ...[
                      // Submitted pending evaluation
                      Container(
                        width: double.maxFinite,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xffEFF6FF)
                                  : const Color(0xff1C1C1F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xffBFDBFE)
                                    : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isKm
                                    ? 'កិច្ចការត្រូវបានប្រគល់រួចរាល់ (រង់ចាំការពិនិត្យ)'
                                    : 'Homework submitted (Pending review)',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // B. Submitted Text Answers
                    Text(
                      isKm ? 'ចម្លើយរបស់អ្នក' : 'Your Submission',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xff475569)
                            : const Color(0xff94A3B8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color(0xff1A1A1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xffE2E8F0)
                                  : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (answerText.trim().isEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.notes,
                                    color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  isKm
                                      ? '(មិនមានអត្ថបទចម្លើយទេ)'
                                      : '(No answer text provided)',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              answerText,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // C. Submitted file attachments
                    Builder(
                      builder: (context) {
                        final pathsToUse = (sub?.filePaths != null &&
                                sub!.filePaths.isNotEmpty)
                            ? sub.filePaths
                            : (filePath != null && filePath.isNotEmpty
                                ? [filePath]
                                : <String>[]);

                        if (pathsToUse.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKm
                                  ? 'ឯកសារចម្លើយដែលបានប្រគល់៖'
                                  : 'Submitted Answer Files:',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            ...pathsToUse.map((path) {
                              final isPdf = path.toLowerCase().endsWith('.pdf');
                              if (isPdf) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => InAppPdfViewer(
                                            url: path,
                                            title: path.split('/').last,
                                          ));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.red.withOpacity(0.3)),
                                        color: Colors.red.withOpacity(0.03),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.picture_as_pdf_outlined,
                                              color: Colors.red,
                                              size: 18),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              path.split('/').last,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.open_in_new,
                                              color: Colors.grey, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () => _showFullScreenImage(path),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? const Color(0xffE2E8F0)
                                            : Colors.white.withOpacity(0.05),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Image.network(
                                            path,
                                            width: double.maxFinite,
                                            height: 160,
                                            fit: BoxFit.cover,
                                          ),
                                          // Minimal corner Zoom overlay
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.zoom_in,
                                                  color: Colors.white,
                                                  size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),

                    // D. Sleek, Quotation-style Teacher Feedback Block
                    if (teacherComment != null &&
                        teacherComment.isNotEmpty) ...[
                      Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xffF8FAFC)
                                  : const Color(0xff1C1C1F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xffE2E8F0)
                                    : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded,
                                    size: 15, color: AppColors.success),
                                const SizedBox(width: 8),
                                Text(
                                  isKm
                                      ? 'មតិយោបល់របស់គ្រូ'
                                      : 'Teacher\'s Comment',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              teacherComment,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color(0xff334155)
                                    : const Color(0xffCBD5E1),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
