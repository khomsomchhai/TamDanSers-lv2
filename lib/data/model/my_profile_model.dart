import 'package:tamdansers_lv2/data/model/profile_model.dart';
import 'package:tamdansers_lv2/data/model/user_model.dart';

class MyProfileModel {
  final UserModel user;
  final ProfileModel profile;

  MyProfileModel({
    required this.user,
    required this.profile,
  });

  factory MyProfileModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? <String, dynamic>{};
    final userJson = data['user'];
    final profileJson = data['profile'];

    return MyProfileModel(
      user: UserModel.fromJson(
        userJson is Map ? Map<String, dynamic>.from(userJson) : null,
      ),
      profile: ProfileModel.fromJson(
        profileJson is Map ? Map<String, dynamic>.from(profileJson) : null,
      ),
    );
  }
}