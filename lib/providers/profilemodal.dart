import 'dart:io'as platform;

import 'package:flutter/material.dart';

import '../models/profiledata.dart';

class ProfileModel with ChangeNotifier {
  ProfileData _profileData = ProfileData();

  void updateProfileData(ProfileData newProfileData) {
    _profileData = newProfileData;
    notifyListeners();
  }

  void updateProfilePicture(platform.File newProfilePicture) {
    //_profileData.profilePicture = newProfilePicture;
    notifyListeners();
  }

  ProfileData get profileData => _profileData;
}
