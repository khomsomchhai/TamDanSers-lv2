class AttendanceModel {
  final int id;
  final int studentId;
  final int scheduleId;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String date;
  final String day;
  final String startTime;
  final String endTime;
  final String status;
  final String remark;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.scheduleId,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.remark,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _asInt(json['id']) ?? 0,
      studentId: _asInt(json['student_id']) ?? 0,
      scheduleId: _asInt(json['schedule_id']) ?? 0,
      classId: _asInt(json['class_id']) ?? 0,
      className: (json['class_name'] ?? '').toString(),
      subjectId: _asInt(json['subject_id']) ?? 0,
      subjectName: (json['subject_name'] ?? '').toString(),
      teacherId: _asInt(json['teacher_id']) ?? 0,
      teacherName: (json['teacher_name'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
