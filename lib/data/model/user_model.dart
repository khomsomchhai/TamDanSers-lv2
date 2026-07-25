class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};

    return UserModel(
      id: data['id'] is int
          ? data['id'] as int
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      avatarUrl: data['avatar_url'] ?? "",
    );
  }
}