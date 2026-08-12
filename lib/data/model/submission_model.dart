class SubmissionModel {
  final int id;
  final int homeworkId;
  final String homeworkTitle;
  final int studentId;
  final String studentName;
  final String answerText;
  final String? filePath;
  final List<String> filePaths;
  final String status;
  final double? score;
  final double bonus;
  final String? teacherComment;
  final String submittedAt;

  SubmissionModel({
    required this.id,
    required this.homeworkId,
    required this.homeworkTitle,
    required this.studentId,
    required this.studentName,
    required this.answerText,
    this.filePath,
    required this.filePaths,
    required this.status,
    this.score,
    required this.bonus,
    this.teacherComment,
    required this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    String? parseFilePath(dynamic rawVal) {
      if (rawVal == null) return null;

      String? strPath;
      if (rawVal is String && rawVal.trim().isNotEmpty) {
        strPath = rawVal.trim();
      } else if (rawVal is List && rawVal.isNotEmpty) {
        return parseFilePath(rawVal.first);
      } else if (rawVal is Map) {
        return parseFilePath(
          rawVal['file_path'] ??
              rawVal['file'] ??
              rawVal['path'] ??
              rawVal['url'] ??
              rawVal['file_url'] ??
              rawVal['attachment'],
        );
      }

      if (strPath == null || strPath.isEmpty) return null;

      if (!strPath.startsWith('http://') && !strPath.startsWith('https://')) {
        if (!strPath.startsWith('/')) {
          strPath = '/$strPath';
        }
        return 'https://tamdansers-1fvbe1msgz9hki.sabay.com$strPath';
      }

      return strPath;
    }

    List<String> parseFilePaths(dynamic rawVal) {
      if (rawVal == null) return [];
      if (rawVal is List) {
        final List<String> result = [];
        for (var item in rawVal) {
          final parsed = parseFilePath(item);
          if (parsed != null && parsed.isNotEmpty) {
            result.add(parsed);
          }
        }
        return result;
      }
      final single = parseFilePath(rawVal);
      return single != null && single.isNotEmpty ? [single] : [];
    }

    dynamic rawSingleFile = json['file_path'] ??
        json['file'] ??
        json['attachment'] ??
        json['attachment_path'] ??
        json['file_url'] ??
        json['url'] ??
        json['filePath'];

    dynamic rawFilesList = json['file_paths'] ?? json['files'];

    final parsedSingle = parseFilePath(rawSingleFile);
    final parsedList = parseFilePaths(rawFilesList);

    final finalPaths = parsedList.isNotEmpty
        ? parsedList
        : (parsedSingle != null ? [parsedSingle] : <String>[]);

    return SubmissionModel(
      id: toInt(json['id'] ?? json['submission_id']),
      homeworkId: toInt(json['homework_id'] ?? json['homeworkId']),
      homeworkTitle: json['homework_title'] ?? json['title'] ?? '',
      studentId: toInt(json['student_id'] ?? json['studentId'] ?? json['user_id']),
      studentName: json['student_name'] ?? json['studentName'] ?? '',
      answerText: json['answer_text'] ?? json['answer'] ?? '',
      filePath: parsedSingle ?? (finalPaths.isNotEmpty ? finalPaths.first : null),
      filePaths: finalPaths,
      status: json['status'] ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      bonus: json['bonus'] != null ? (json['bonus'] as num).toDouble() : 0.0,
      teacherComment: json['teacher_comment'],
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}
