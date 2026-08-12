class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? phone;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.phone,
  });

  String get displayName =>
      fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

  String get name => displayName;

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};

    return UserModel(
      id: data['id'] is int
          ? data['id'] as int
          : int.tryParse(
                data['id']?.toString() ?? '',
              ) ??
              0,
      firstName:
          data['first_name']?.toString() ?? '',
      lastName:
          data['last_name']?.toString() ?? '',
      fullName:
          data['full_name']?.toString() ?? '',
      email:
          data['email']?.toString() ?? '',
      role:
          data['role']?.toString() ?? '',
      avatarUrl:
          data['avatar_url']?.toString(),
      phone:
          data['phone']?.toString(),
    );
  }

  String _formatPhone(String? raw) {
    if (raw == null) return '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
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

    return raw.trim();
  }

  String get formattedPhone => _formatPhone(phone);
}