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

    final userJsonRaw = data['user'];
    final profileJsonRaw = data['profile'];

    final Map<String, dynamic>? userMap =
        userJsonRaw is Map ? Map<String, dynamic>.from(userJsonRaw) : null;
    final Map<String, dynamic>? profileMap = profileJsonRaw is Map
        ? Map<String, dynamic>.from(profileJsonRaw)
        : null;
    final Map<String, dynamic> mergedUser =
        Map<String, dynamic>.from(userMap ?? <String, dynamic>{});

    if ((mergedUser['phone'] == null ||
            mergedUser['phone'].toString().trim().isEmpty) &&
        profileMap != null &&
        profileMap['phone'] != null) {
      mergedUser['phone'] = profileMap['phone'];
    }

    return MyProfileModel(
      user: UserModel.fromJson(mergedUser),
      profile: ProfileModel.fromJson(profileMap),
    );
  }
}