class StudentModel {
  final int id;
  final String studentCode;
  final String studentName;
  final int classId;
  final String className;
  final String gender;
  final String guardianName;
  final String guardianPhone;
  final String address;

  StudentModel({
    required this.id,
    required this.studentCode,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.gender,
    required this.guardianName,
    required this.guardianPhone,
    required this.address,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? 0,
      studentCode: map['student_code'] ?? '',
      studentName: map['student_name'] ?? '',
      classId: map['class_id'] ?? 0,
      className: map['class_name'] ?? '',
      gender: map['gender'] ?? '',
      guardianName: map['guardian_name'] ?? '',
      guardianPhone: map['guardian_phone'] ?? '',
      address: map['address'] ?? '',
    );
  }
}