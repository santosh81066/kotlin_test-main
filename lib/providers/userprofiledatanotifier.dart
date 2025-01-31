import 'dart:convert';
import 'dart:io' as platform;
import 'dart:io';
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

  void setImageFile(XFile? file) {
    if (file != null) {
      state.data![0] = UserProfileData(
        id: state.data![0].id,
        username: state.data![0].username,
        mobileno: state.data![0].mobileno,
        profilepic: state.data![0].profilepic,
        adhar: state.data![0].adhar,
        languages: state.data![0].languages,
        expirience: state.data![0].expirience,
        role: state.data![0].role,
        userstatus: state.data![0].userstatus,
        isonline: state.data![0].isonline,
        imageurl: state.data![0].imageurl,
        adharno: state.data![0].adharno,
        location: state.data![0].location,
        dateofbirth: state.data![0].dateofbirth,
        placeofbirth: state.data![0].placeofbirth,
        xfile: file, // Update the xfile field
      );
    }
  }

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

  Future<void> getUser(BuildContext cont, WidgetRef ref) async {
    print('DEBUG: getUser method started');
    final loadingState = ref.read(loadingProvider.notifier);
    loadingState.state = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      String? savedUserResponseJson = prefs.getString('userResponse');

      if (savedUserResponseJson != null) {
        Map<String, dynamic> savedUserResponse =
            json.decode(savedUserResponseJson);
        state = ProfileData.fromJson(savedUserResponse);

        print('DEBUG: Saved user data loaded');
        print('DEBUG: Username: ${state.data?[0].username}');
        print('DEBUG: Profile complete: ${prefs.getBool('profile')}');
      }

      final url = PurohitApi().baseUrl + PurohitApi().login;
      final token = authNotifier.state.accessToken;
      final databaseReference = FirebaseDatabase.instance.ref();
      final fbuser = FirebaseAuth.instance.currentUser;
      final uid = fbuser?.uid;

      if (token == null) {
        print('DEBUG: No access token found');
        // Handle case where no token exists
        Navigator.of(cont).pushReplacementNamed('login');
        loadingState.state = false;
        return;
      }

      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
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
          'Authorization': token
        },
      );

      Map<String, dynamic> userResponse = json.decode(response.body);
      state = ProfileData.fromJson(userResponse);

      print('DEBUG: Server user response received');
      print('DEBUG: Server username: ${state.data?[0].username}');

      if (state.data != null && state.data!.isNotEmpty) {
        await prefs.setString('userResponse', json.encode(userResponse));
        var userData = state.data![0];

        // Detailed navigation logic with extensive logging
        if (userData.username == null || userData.username!.isEmpty) {
          print('DEBUG: No username, navigating to saveprofile');
          Navigator.of(cont).pushReplacementNamed('saveprofile');
        } else {
          print('DEBUG: Username exists, setting profile to true');
          await prefs.setBool('profile', true);

          // Check current route before navigation
          bool isAlreadyOnWelcome = false;
          Navigator.popUntil(cont, (route) {
            if (route.settings.name == 'wellcome') {
              isAlreadyOnWelcome = true;
            }
            return true;
          });

          if (!isAlreadyOnWelcome) {
            print('DEBUG: Navigating to wellcome page');
            Navigator.of(cont).pushReplacementNamed('wellcome');
          } else {
            print('DEBUG: Already on wellcome page, skipping navigation');
          }
        }
      } else {
        print('DEBUG: No user data received from server');
        // Handle case with no user data
        Navigator.of(cont).pushReplacementNamed('login');
      }
    } catch (e) {
      print('DEBUG: Error in getUser method: $e');
      // Handle error - maybe navigate to login or show error
      Navigator.of(cont).pushReplacementNamed('login');
    } finally {
      loadingState.state = false;
    }
  }

  Future updateUser(
      String? username, String? pob, String? dob, BuildContext context) async {
    const url = "https://talk2purohit.com/saveprofile";
    String randomLetters = generateRandomLetters(10);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = authNotifier.state.accessToken;
    try {
      print('Updating user with:');
      print('Username: $username');
      print('Place of Birth: $pob');
      print('Date of Birth: $dob');
      print('Has image file: ${state.data![0].xfile != null}');

      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await authNotifier.restoreAccessToken();
            req.headers['Authorization'] = accessToken;
          }
        },
      );

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': token!,
      });
      request.fields['username'] = username!;
      request.fields['dob'] = dob!;
      request.fields['pob'] = pob!;

      if (state.data![0].profilepic == null) {
        request.fields['profilepic'] = "${randomLetters}_profilepic";
      }

      if (state.data![0].xfile != null) {
        print('Image file path: ${state.data![0].xfile!.path}');
        request.files.add(await http.MultipartFile.fromPath(
            'image', state.data![0].xfile!.path));
      }

      var response = await client.send(request);
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      print("Update response status: ${response.statusCode}");
      print("Update response body: $jsonResponse");

      if (response.statusCode == 200) {
        // Update local SharedPreferences with new user data
        await prefs.setString(
            'userResponse',
            json.encode({
              'data': [
                {
                  'id': state.data![0].id,
                  'username': username,
                  'dateofbirth': dob,
                  'placeofbirth': pob,
                  // Add other fields as needed
                }
              ]
            }));

        // Update the current state
        state = ProfileData.fromJson({
          'data': [
            {
              'id': state.data![0].id,
              'username': username,
              'dateofbirth': dob,
              'placeofbirth': pob,
              // Preserve other existing fields
              ...state.data![0].toJson()
            }
          ]
        });

        prefs.setBool('profile', true);
      }

      return jsonResponse["success"];
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  void navigateBasedOnUserData(BuildContext context) {
    print('DEBUG: navigateBasedOnUserData called');

    if (state.data != null && state.data!.isNotEmpty) {
      var userData = state.data![0];

      // Extensive logging
      print('DEBUG: User data exists');
      print('DEBUG: Username: ${userData.username}');

      // Check if already on welcome page to prevent repeated navigation
      bool isCurrentRouteWelcome = false;
      Navigator.popUntil(context, (route) {
        if (route.settings.name == 'wellcome') {
          isCurrentRouteWelcome = true;
        }
        return true;
      });

      if (userData.username != null && !isCurrentRouteWelcome) {
        print('DEBUG: Navigating to wellcome page');
        Navigator.of(context).pushNamed('wellcome');
      } else if (userData.username == null && !isCurrentRouteWelcome) {
        print('DEBUG: Navigating to saveprofile page');
        Navigator.of(context).pushReplacementNamed('saveprofile');
      } else {
        print('DEBUG: No navigation needed');
      }
    } else {
      print('DEBUG: No user data found');
      // Consider navigating to login or handling this case
    }
  }

  String generateRandomLetters(int length) {
    var random = Random();
    var letters = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(letters);
  }

  Future<void> getUserPic(BuildContext cont, WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = PurohitApi().baseUrl + PurohitApi().userProfile;
    final loadingState = ref.read(loadingProvider.notifier);
    loadingState.state = true;
    final token = authNotifier.state.accessToken;
    // Check for cached image
    String? cachedBase64String = prefs.getString('userProfilePic');
    if (cachedBase64String != null) {
      final Uint8List bytes = base64Decode(cachedBase64String);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/profile');
      await file.writeAsBytes(bytes);
      if (state.data != null) {
        state.data![0].xfile = XFile(file.path);
      }
      loadingState.state = false;
      return;
    }
    final client = RetryClient(
      http.Client(),
      retries: 4,
      when: (response) {
        return response.statusCode == 401 ? true : false;
      },
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          var accessToken =
              await authNotifier.restoreAccessToken(call: "get user pic");
          // Only this block can run (once) until done

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
    //Map<String, dynamic> userResponse = json.decode(response.body);

    switch (response.statusCode) {
      case 200:

        // Attempt to create an Image object from the image bytes
        // final image = Image.memory(resbytes);
        final Uint8List resbytes = response.bodyBytes;

        // Cache image
        String base64String = base64Encode(resbytes);
        await prefs.setString('userProfilePic', base64String);

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/profile');
        await file.writeAsBytes(resbytes);
        if (state.data != null) {
          state.data![0].xfile = XFile(file.path);
        }

        // If the image was created successfully, the bytes are in a valid format

        loadingState.state = false;
    }

    // print(
    //     "this is from getuserPic:${userDetails!.data![0].xfile!.readAsBytes()}");
  }

  Future<void> updateUserModel(String id, UserProfileData newUser) async {
    state = state.updateUserProfile(id, newUser);
  }
}

final userProfileDataProvider =
    StateNotifierProvider<UserProfileDataNotifier, ProfileData>((ref) {
  print('Updating state with user response');
  final authNotifier = ref.watch(authProvider.notifier);
  return UserProfileDataNotifier(authNotifier);
});
