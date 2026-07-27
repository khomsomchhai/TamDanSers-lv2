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

  factory ProfileModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ProfileModel(
      id: parseInt(data['id'] ?? data['student_id']),
      studentCode: data['student_code'] ?? '',
      userId: parseInt(data['user_id']),
      classId: parseInt(data['class_id']),
      className: data['class_name'] ?? '',
      rollNo: data['roll_no']?.toString(),
      gender: data['gender'] ?? '',
      guardianName: data['guardian_name'] ?? '',
      guardianPhone: data['guardian_phone'] ?? '',
      address: data['address'] ?? '',
    );
  }
}
