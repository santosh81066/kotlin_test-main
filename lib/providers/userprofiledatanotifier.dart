import 'dart:convert';
import 'dart:io' as platform;
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../models/profiledata.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';
import 'loader.dart';

class UserProfileDataNotifier extends StateNotifier<ProfileData> {
  final AuthNotifier authNotifier;
  UserProfileDataNotifier(this.authNotifier) : super(ProfileData());

  /// Sets the image file and updates both the state and SharedPreferences.
  void setImageFile(XFile? file) async {
    if (file != null) {
      state = state.copyWith(
        data: [
          state.data![0].copyWith(xfile: file),
        ],
      );

      // Save updated state to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userResponse', json.encode(state.toJson()));
    }
  }

  /// Retrieves the image file associated with the user.
  Future<platform.File?> getImageFile(BuildContext context) async {
    if (state.data != null) {
      final data = state.data![0];
      if (data.xfile == null) {
        return null;
      }
      final platform.File file = platform.File(data.xfile!.path);
      return file;
    }

    return null;
  }

  /// Retrieves the user profile picture from local storage or API.
  Future<Uint8List?> getUserPic(BuildContext context, WidgetRef ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserResponseJson = prefs.getString('userResponse');

    if (savedUserResponseJson != null) {
      Map<String, dynamic> savedUserResponse =
          json.decode(savedUserResponseJson);
      state = ProfileData.fromJson(savedUserResponse);

      if (state.data != null) {
        var profilePic = state.data![0].profilepic;
        if (profilePic != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = '${directory.path}/$profilePic';
          final imageFile = platform.File(imagePath);

          if (await imageFile.exists()) {
            return await imageFile.readAsBytes();
          }
        }
      }
    }
    print('Profile Pic: ${state.data![0].profilepic}');

    return null;
  }

  /// Fetches the user data, rehydrates state from SharedPreferences if available.
  Future<void> getUser(BuildContext cont, WidgetRef ref) async {
    print('get user started');
    final loadingState = ref.read(loadingProvider.notifier);
    loadingState.state = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check for cached user data
    String? savedUserResponseJson = prefs.getString('userResponse');
    if (savedUserResponseJson != null) {
      Map<String, dynamic> savedUserResponse =
          json.decode(savedUserResponseJson);
      state = ProfileData.fromJson(savedUserResponse);

      Future.delayed(Duration.zero).then(
        (value) => navigateBasedOnUserData(cont),
      );
      return; // Exit if data is already available
    }

    // Proceed with fetching data from API
    final url = PurohitApi().baseUrl + PurohitApi().login;
    final token = authNotifier.state.accessToken;
    final databaseReference = FirebaseDatabase.instance.ref();
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;

    final client = RetryClient(
      http.Client(),
      retries: 4,
      when: (response) => response.statusCode == 401,
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          var accessToken =
              await authNotifier.restoreAccessToken(call: "get user");
          req.headers['Authorization'] = accessToken;
        }
      },
    );

    var response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token!
      },
    );

    Map<String, dynamic> userResponse = json.decode(response.body);
    state = ProfileData.fromJson(userResponse);

    if (state.data != null && state.data!.isNotEmpty) {
      await prefs.setString('userResponse', json.encode(userResponse));
      var userData = state.data![0];

      final userDataSnapshot = await databaseReference
          .child('users')
          .child(uid!)
          .orderByChild('id')
          .equalTo('${userData.id}')
          .once();

      if (userDataSnapshot.snapshot.value == null) {
        await databaseReference
            .child('users')
            .child(uid)
            .set(userData.toJson());
      }

      if (userData.username == null || userData.username!.isEmpty) {
        Navigator.of(cont).pushReplacementNamed('saveprofile');
      } else {
        await prefs.setBool('profile', true);
        Navigator.of(cont).pushReplacementNamed('wellcome');
      }
    }
    loadingState.state = false;
  }

  /// Updates the user details and persists the changes in SharedPreferences.
  Future updateUser(
      String? username, String? pob, String? dob, BuildContext context) async {
    const url = "https://talk2purohit.com/saveprofile";
    String randomLetters = generateRandomLetters(10);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = authNotifier.state.accessToken;

    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) => response.statusCode == 401,
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await authNotifier.restoreAccessToken();
            req.headers['Authorization'] = accessToken;
          }
        },
      );

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': token!});
      request.fields['username'] = username!;
      request.fields['dob'] = dob!;
      request.fields['pob'] = pob!;
      if (state.data![0].profilepic == null) {
        request.fields['profilepic'] = "${randomLetters}_profilepic";
      }
      if (state.data![0].xfile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'image', state.data![0].xfile!.path));
      }

      var response = await client.send(request);
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        prefs.setBool('profile', true);

        // Update local state
        state = state.copyWith(
          data: [
            state.data![0].copyWith(
              username: username,
              placeofbirth: pob,
              dateofbirth: dob,
            ),
          ],
        );

        // Persist updated state
        prefs.setString('userResponse', json.encode(state.toJson()));
      }

      return jsonResponse["success"];
    } catch (e) {
      return false;
    }
  }

  /// Updates user model and persists the changes in SharedPreferences.
  Future<void> updateUserModel(String id, UserProfileData newUser) async {
    state = state.updateUserProfile(id, newUser);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userResponse', json.encode(state.toJson()));
  }

  String generateRandomLetters(int length) {
    var random = Random();
    var letters = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(letters);
  }

  void navigateBasedOnUserData(BuildContext context) {
    if (state.data != null) {
      var userData = state.data![0];

      // Check if the current route is 'home'
      bool isCurrentRouteHome = false;
      Navigator.popUntil(context, (route) {
        if (route.settings.name == 'wellcome') {
          isCurrentRouteHome = true;
        }
        return true;
      });

      if (userData.username != null && !isCurrentRouteHome) {
        Navigator.of(context).pushNamed('wellcome');
      } else if (userData.username == null && !isCurrentRouteHome) {
        Navigator.of(context).pushReplacementNamed('saveprofile');
      }
    }
  }
}

final userProfileDataProvider =
    StateNotifierProvider<UserProfileDataNotifier, ProfileData>((ref) {
  print('Updating state with user response');
  final authNotifier = ref.watch(authProvider.notifier);
  return UserProfileDataNotifier(authNotifier);
});
