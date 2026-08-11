class HomeworkModel {
  final int id;
  final String title;
  final String description;
  final String? filePath;
  final List<String> filePaths;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String dueDate;
  final String createdAt;

  HomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    this.filePath,
    this.filePaths = const [],
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.dueDate,
    required this.createdAt,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic val) {
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

    dynamic rawFile = json['file_path'] ??
        json['file'] ??
        json['attachment'] ??
        json['attachment_path'] ??
        json['file_url'] ??
        json['url'] ??
        json['filePath'] ??
        json['files'];

    final parsedPaths = parseFilePaths(rawFile);
    final singlePath = parsedPaths.isNotEmpty ? parsedPaths.first : null;

    return HomeworkModel(
      id: _toInt(json['id'] ?? json['homework_id']),
      title: json['title'] ?? json['homework_title'] ?? '',
      description: json['description'] ?? '',
      filePath: singlePath,
      filePaths: parsedPaths,
      classId: _toInt(json['class_id'] ?? json['classId']),
      className: json['class_name'] ?? json['className'] ?? '',
      subjectId: _toInt(json['subject_id'] ?? json['subjectId']),
      subjectName: json['subject_name'] ?? json['subjectName'] ?? '',
      teacherId: _toInt(json['teacher_id'] ?? json['teacherId']),
      teacherName: json['teacher_name'] ?? json['teacherName'] ?? '',
      dueDate: json['due_date'] ?? json['dueDate'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }
}
