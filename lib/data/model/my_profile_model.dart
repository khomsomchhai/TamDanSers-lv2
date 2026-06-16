import 'package:tamdansers_lv2/data/model/profile_model.dart';
import 'package:tamdansers_lv2/data/model/user_model.dart';

class MyProfileModel {
  final UserModel user;
  final ProfileModel profile;

  MyProfileModel({
    required this.user,
    required this.profile,
  });

  factory MyProfileModel.fromJson(Map<String, dynamic> json) {
    return MyProfileModel(
      user: UserModel.fromJson(json['user']) ,
      profile: ProfileModel.fromJson(json['profile']),
    );
  }
}