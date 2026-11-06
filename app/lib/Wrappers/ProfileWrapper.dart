import 'dart:convert';

import 'package:creativetrainclient/Wrappers/GeneralConfig.dart';
import 'package:creativetrainclient/Wrappers/RoleConfigData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileWrapper {
  final GeneralConfig generalConfig;
  final RoleConfigData roleConfigData;
  final String profileName;

  ProfileWrapper({
    required this.generalConfig,
    required this.roleConfigData,
    required this.profileName,
  });

  factory ProfileWrapper.fromJson(Map<String, dynamic> json) {
    return ProfileWrapper(
      generalConfig: json['generalConfig'],
      roleConfigData: json['roleConfigData'],
      profileName: json['profileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalConfig': generalConfig,
      'roleConfigData': roleConfigData,
      'profileName': profileName,
    };
  }
}

class ProfileManager {
  static Future<List<ProfileWrapper>> getAllProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getStringList('user_profiles');

    if (jsonString == null) return [];

    final profiles = <ProfileWrapper>[];
    for (final item in jsonString) {
      try {
        final profile = ProfileWrapper.fromJson(json.decode(item));
        profiles.add(profile);
      } catch (e) {
        print('Error parsing profile: $e');
      }
    }
    return profiles;
  }

  static Future<void> deleteProfile(String profileName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getStringList('user_profiles');

    if (jsonString == null) return;

    final index = jsonString.indexWhere((item) {
      final profile = ProfileWrapper.fromJson(json.decode(item));
      return profile.profileName == profileName;
    });

    if (index != -1) {
      final newList = List<String>.from(jsonString);
      newList.removeAt(index);
      await prefs.setStringList('user_profiles', newList);
    }
  }

  static Future<void> saveProfile(
    ProfileWrapper profile, {
    bool overwrite = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getStringList('user_profiles');
    if (jsonString != null) {
      final index = jsonString.indexWhere((item) {
        final profile = ProfileWrapper.fromJson(json.decode(item));
        return profile.profileName == profile.profileName;
      });

      if (index != -1) {
        if (!overwrite) return;
      }
    }

    final newProfile = profile.toJson();
    final jsonList = prefs.getStringList('user_profiles') ?? [];
    final updatedList = List<String>.from(jsonList)
      ..add(json.encode(newProfile));
    await prefs.setStringList('user_profiles', updatedList);
  }
}
