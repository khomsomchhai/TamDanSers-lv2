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

    String sanitizePlaceholderName(String? value) {
      final String text = value?.trim() ?? '';
      if (text.isEmpty) {
        return '';
      }

      if (text.toLowerCase() == 'guardian') {
        return '';
      }

      return text;
    }

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
      guardianName: sanitizePlaceholderName(data['guardian_name']),
      guardianPhone: data['guardian_phone'] ?? '',
      address: data['address'] ?? '',
    );
  }

  String _formatPhone(String? raw) {
    if (raw == null) return '';
    final digits = raw.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    var normalized = digits;
    if (normalized.startsWith('855')) {
      normalized = normalized.substring(3);
    }
    if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }

    if (normalized.length >= 8) {
      final part1 = normalized.substring(0, 2);
      final part2 = normalized.length >= 5
          ? normalized.substring(2, 5)
          : normalized.substring(2);
      final part3 = normalized.length > 5
          ? normalized.substring(5)
          : '';
      return part3.isNotEmpty
          ? '+855 $part1 $part2 $part3'
          : '+855 $part1 $part2';
    }

    return raw.toString().trim();
  }

  String get formattedGuardianPhone => _formatPhone(guardianPhone);
}
