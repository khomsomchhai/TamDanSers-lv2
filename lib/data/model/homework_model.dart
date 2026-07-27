class HomeworkModel {
  final int id;
  final String title;
  final String description;
  final String? filePath;
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

    return HomeworkModel(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      filePath: json['file_path'],
      classId: _toInt(json['class_id']),
      className: json['class_name'] ?? '',
      subjectId: _toInt(json['subject_id']),
      subjectName: json['subject_name'] ?? '',
      teacherId: _toInt(json['teacher_id']),
      teacherName: json['teacher_name'] ?? '',
      dueDate: json['due_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
