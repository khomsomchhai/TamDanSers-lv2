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
}