import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/authstate.dart';
import '../utils/purohitapi.dart';
import 'userprofiledatanotifier.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print('trylogin is false');
      return false;
    }

    final extractData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final profile = prefs.getBool('profile') ?? false;
    final expiryDate = DateTime.parse(extractData['refreshExpiry']);
    final accessExpiry = DateTime.parse(extractData['accessTokenExpiry']);

    state = state.copyWith(
      sessionId: extractData['sessionId'],
      mobileno: extractData['userId'],
      refreshToken: extractData['refreshToken'],
      accessToken: extractData['accessToken'],
      refreshTokenExpiryDate: expiryDate,
      accessTokenExpiryDate: accessExpiry,
      profile: profile,
      ftoken: prefs.getString('firebaseToken'),
    );
    print('access token from try auto login:${state.accessToken}');
    return true;
  }

  Future<int> registerUser(
      BuildContext context, String? phoneNumber, WidgetRef ref) async {
    final url = PurohitApi().baseUrl + PurohitApi().login;

    final prefs = await SharedPreferences.getInstance();
    var data = {
      "mobileno": phoneNumber,
      "role": "u",
      "userstatus": "1",
    };
    Map<String, String> obj = {"attributes": json.encode(data).toString()};

    var response = http.MultipartRequest('POST', Uri.parse(url))
      ..fields.addAll(obj);
    final send = await response.send();
    final res = await http.Response.fromStream(send);
    var userDetails = json.decode(res.body);

    if (res.statusCode == 201) {
      // Update the state with the new data
      state = state.copyWith(
        sessionId: userDetails['data']['session_id'],
        mobileno: userDetails['data']['mobileno'],
        accessToken: userDetails['data']['access_token'],
        accessTokenExpiryDate: DateTime.now().add(
            Duration(seconds: userDetails['data']['access_token_expires_in'])),
        refreshToken: userDetails['data']['refresh_token'],
        refreshTokenExpiryDate: DateTime.now().add(
            Duration(seconds: userDetails['data']['refresh_token_expires_in'])),
        messages: userDetails['messages'].toString(),
        // Add other fields if necessary
      );

      final userData = json.encode({
        'sessionId': state.sessionId,
        'userId': state.mobileno,
        'refreshToken': state.refreshToken,
        'refreshExpiry': state.refreshTokenExpiryDate!.toIso8601String(),
        'accessToken': state.accessToken,
        'accessTokenExpiry': state.accessTokenExpiryDate!.toIso8601String(),
      });

      await prefs.setString('userData', userData);
      print('register user ${prefs.getString('userData')}');
      await ref.read(userProfileDataProvider.notifier).getUser(context, ref);
      // Remove navigation logic from here, handle it in the UI layer
    }

    // Handle other status codes as needed

    return res.statusCode;
  }

  Future<String> restoreAccessToken({String? call}) async {
    print("restore access started $call");
    final url =
        '${PurohitApi().baseUrl}${PurohitApi().login}/${state.sessionId}';

    final prefs = await SharedPreferences.getInstance();

    try {
      var response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': state.accessToken!,
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({"refresh_token": state.refreshToken}),
      );

      var userDetails = json.decode(response.body);
      print('restore token response $userDetails');
      switch (response.statusCode) {
        case 401:
          // Handle 401 Unauthorized
          // await logout();
          // await tryAutoLogin();
          print("shared preferance ${prefs.getString('userData')}");
          print('access token from restoreAccessToken:${state.accessToken}');
          break;
        case 200:
          print("refresh access token success");
          final newAccessToken = userDetails['data']['access_token'];
          final newAccessTokenExpiryDate = DateTime.now().add(
            Duration(seconds: userDetails['data']['access_token_expiry']),
          );
          final newRefreshToken = userDetails['data']['refresh_token'];
          final newRefreshTokenExpiryDate = DateTime.now().add(
            Duration(seconds: userDetails['data']['refresh_token_expiry']),
          );
          print('new accesstoken :$newAccessToken');
          // Update state
          state = state.copyWith(
            accessToken: newAccessToken,
            accessTokenExpiryDate: newAccessTokenExpiryDate,
            refreshToken: newRefreshToken,
            refreshTokenExpiryDate: newRefreshTokenExpiryDate,
          );
          print('access token from restoreAccessToken:${state.accessToken}');
          final userData = json.encode({
            'sessionId': state.sessionId,
            'refreshToken': newRefreshToken,
            'refreshExpiry': newRefreshTokenExpiryDate.toIso8601String(),
            'accessToken': newAccessToken,
            'accessTokenExpiry': newAccessTokenExpiryDate.toIso8601String(),
          });

          prefs.setString('userData', userData);
          print(
              "shared preferance after success  ${prefs.getString('userData')}");
        // loading(false); // Update loading state
      }
    } on FormatException catch (formatException) {
      print('Format Exception: ${formatException.message}');
      print('Invalid response format.');
    } on HttpException catch (httpException) {
      print('HTTP Exception: ${httpException.message}');
    } catch (e) {
      print('General Exception: ${e.toString()}');
      if (e is Error) {
        print('Stack Trace: ${e.stackTrace}');
      }
    }
    return state.accessToken!;
  }

  Future<void> logout() async {
    final url =
        '${PurohitApi().baseUrl}${PurohitApi().login}/${state.sessionId}';

    // Logout request to the server
    await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': state.accessToken!,
      },
    );

    // Cancel any running timers

    // Clear the shared preferences except for 'profile'
    final prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key != 'profile') {
        prefs.remove(key);
      }
    }

    // Reset the state to initial
    state = AuthState.initial();
  }

  // Other methods...
}
// Other methods can be added here

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
