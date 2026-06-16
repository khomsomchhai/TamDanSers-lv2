class ProfileModel {
  final int id;
  final String studentCode;
  final int userId;
  final int classId;
  final String className;
  final String? rollNo;
  final String gender;
  final String guardianName;
  final String guardianPhone;
  final String address;

  ProfileModel({
    required this.id,
    required this.studentCode,
    required this.userId,
    required this.classId,
    required this.className,
    this.rollNo,
    required this.gender,
    required this.guardianName,
    required this.guardianPhone,
    required this.address,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      studentCode: json['student_code'] ?? '',
      userId: json['user_id'] ?? "",
      classId: json['class_id'] ?? "",
      className: json['class_name'] ?? '',
      rollNo: json['roll_no'] ?? "",
      gender: json['gender'] ?? '',
      guardianName: json['guardian_name'] ?? '',
      guardianPhone: json['guardian_phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}