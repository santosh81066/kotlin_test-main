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
    print('get user started');
    final loadingState = ref.read(loadingProvider.notifier);
    loadingState.state = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserResponseJson = prefs.getString('userResponse');
    if (savedUserResponseJson != null) {
      // Decode the JSON string back into a Map
      Map<String, dynamic> savedUserResponse =
          json.decode(savedUserResponseJson);

      // Update your state with the saved user response
      state = ProfileData.fromJson(savedUserResponse);
      Future.delayed(Duration.zero).then(
        (value) {
          navigateBasedOnUserData(cont);
        },
      );
      // Proceed with the rest of your logic, e.g., navigation

      return; // Exit the function as you already have the data
    }
    final url = PurohitApi().baseUrl + PurohitApi().login;
    final token = authNotifier.state.accessToken;
    final databaseReference = FirebaseDatabase.instance.ref();
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;

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
    Map<String, dynamic> userResponse = json.decode(response.body);
    state = ProfileData.fromJson(userResponse);
    // Check if any user details are null and set profile status accordingly
    print('get user response $userResponse');
    if (state.data != null && state.data!.isNotEmpty) {
      await prefs.setString('userResponse', json.encode(userResponse));
      var userData = state.data![0]; // Get the first userData object
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
        print('there is no username');
        // If username is null or empty, navigate to SaveProfilePage
        Navigator.of(cont).pushReplacementNamed('saveprofile');
        loadingState.state = false;
      } else {
        print('there is username');
        await prefs.setBool('profile', true);
        // If username is not null, navigate to HomePage
        Navigator.of(cont).pushReplacementNamed('wellcome');
        loadingState.state = false;
      }
    }
    loadingState.state = false;
  }

  Future updateUser(
      String? username, String? pob, String? dob, BuildContext context) async {
    const url = "https://purohithuluapp.in/saveprofile";
    String randomLetters = generateRandomLetters(10);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = authNotifier.state.accessToken;
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await authNotifier.restoreAccessToken();
            // Only this block can run (once) until done

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
        request.files.add(await http.MultipartFile.fromPath(
            'image', state.data![0].xfile!.path));
      }

      var response = await client.send(request);
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      print("update response:$jsonResponse ${response.statusCode}");
      if (response.statusCode == 200) {
        prefs.setBool('profile', true);

      }

      return jsonResponse["success"];
    } catch (e) {
      if (e is FormatException) {
        // handle the format exception here
      } else {
        // handle other exceptions here
      }

      return false;
    }
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
        return true; // Do not actually pop the route
      });

      if (userData.username != null && !isCurrentRouteHome) {
        // If user data is valid and not already on the home route, navigate to home
        Navigator.of(context).pushNamed('wellcome');
      } else if (userData.username == null && !isCurrentRouteHome) {
        Navigator.of(context).pushReplacementNamed('saveprofile');
      }
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
