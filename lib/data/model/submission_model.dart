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

    return SubmissionModel(
      id: toInt(json['id']),
      homeworkId: toInt(json['homework_id']),
      homeworkTitle: json['homework_title'] ?? '',
      studentId: toInt(json['student_id']),
      studentName: json['student_name'] ?? '',
      answerText: json['answer_text'] ?? '',
      filePath: json['file_path'],
      filePaths: json['file_paths'] != null
          ? List<String>.from(json['file_paths'])
          : [],
      status: json['status'] ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      bonus: json['bonus'] != null ? (json['bonus'] as num).toDouble() : 0.0,
      teacherComment: json['teacher_comment'],
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}
