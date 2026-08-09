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
  final String profileImage;

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
    this.profileImage = '',
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    final image = map['profile_image'] ??
        map['profile_photo'] ??
        map['avatar_url'] ??
        map['avatar'] ??
        map['photo_url'] ??
        map['photo'] ??
        map['image'] ??
        map['picture'] ??
        map['img'] ??
        map['student_image'] ??
        map['student_photo'] ??
        map['user']?['profile_image'] ??
        map['user']?['avatar_url'] ??
        map['user']?['avatar'] ??
        map['user']?['photo'] ??
        '';

    int parseId(dynamic val) {
      if (val is int) return val;
      if (val != null) {
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
      return 0;
    }

    final rawId = map['id'] ?? map['student_id'] ?? map['studentId'] ?? map['user_id'] ?? map['userId'];
    final rawClassId = map['class_id'] ?? map['classId'];

    return StudentModel(
      id: parseId(rawId),
      studentCode: (map['student_code'] ?? map['code'] ?? map['studentCode'] ?? '').toString(),
      studentName: (map['student_name'] ?? map['name'] ?? map['full_name'] ?? map['studentName'] ?? '').toString(),
      classId: parseId(rawClassId),
      className: (map['class_name'] ?? map['className'] ?? map['class'] ?? '').toString(),
      gender: (map['gender'] ?? '').toString(),
      guardianName: (map['guardian_name'] ?? map['guardianName'] ?? '').toString(),
      guardianPhone: (map['guardian_phone'] ?? map['guardianPhone'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      profileImage: image.toString(),
    );
  }
}