// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:kotlin_test/utils/purohitapi.dart';

// import 'package:provider/provider.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'api_calls.dart';

// class AuthenticationDetails extends ChangeNotifier {
//   var isloading = false;
//   int? mobileno;
//   Timer? authTimer;
//   String? messages;
//   int? sessionId;
//   String? accessToken;
//   DateTime? accessTokenExpiryDate;
//   String? refreshToken;
//   DateTime? refreshTokenExpiryDate;
//   bool profile = false;
//   String? ftoken;
//   String? verificationId;
//   FirebaseAuth auth = FirebaseAuth.instance;
//   bool get isAuthoutised {
//     return accesstoken != null;
//   }

//   String? get accesstoken {
//     if (accessTokenExpiryDate != null &&
//         accessTokenExpiryDate!.isAfter(DateTime.now()) &&
//         accessToken != null) {
//       return accessToken;
//     }
//     return null;
//   }

//   bool get isAuth {
//     return refreshtoken != null;
//   }

//   bool get isProfile {
//     return profile = true;
//   }

//   String? get refreshtoken {
//     if (refreshTokenExpiryDate != null &&
//         refreshTokenExpiryDate!.isAfter(DateTime.now()) &&
//         refreshToken != null) {
//       return refreshToken;
//     }
//     return null;
//   }

//   loading(bool load) {
//     isloading = load;
//     notifyListeners();
//   }

//   Future<void> logout() async {
//     final url = '${PurohitApi().baseUrl}${PurohitApi().login}/$sessionId';
//     await http.delete(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': accessToken!
//       },
//     );

//     if (authTimer != null) {
//       authTimer!.cancel();
//       authTimer = null;
//     }

//     refreshToken = null;
//     refreshTokenExpiryDate = null;
//     final prefs = await SharedPreferences.getInstance();
//     Set<String> keys = prefs.getKeys();
//     for (String key in keys) {
//       if (key != 'profile') {
//         prefs.remove(key);
//       }
//     }
//     notifyListeners();
//   }

//   Future<String> restoreAccessToken() async {
//     final url = '${PurohitApi().baseUrl}${PurohitApi().login}/$sessionId';
//     final prefs = await SharedPreferences.getInstance();

//     loading(true);
//     var response = await http.patch(Uri.parse(url),
//         headers: {
//           'Authorization': accessToken!,
//           'Content-Type': 'application/json; charset=UTF-8'
//         },
//         body: json.encode({"refresh_token": refreshToken}));

//     var userDetails = json.decode(response.body);
//     switch (response.statusCode) {
//       case 401:
//         logout();
//         //tryAutoLogin();
//         loading(false);
//         notifyListeners();
//         break;
//       case 200:
//         sessionId = userDetails['data']['session_id'];
//         accessToken = userDetails['data']['access_token'];
//         accessTokenExpiryDate = DateTime.now()
//             .add(Duration(seconds: userDetails['data']['access_token_expiry']));
//         refreshToken = userDetails['data']['refresh_token'];
//         refreshTokenExpiryDate = DateTime.now().add(
//             Duration(seconds: userDetails['data']['refresh_token_expiry']));

//         final userData = json.encode({
//           'sessionId': sessionId,
//           'refreshToken': refreshToken,
//           'refreshExpiry': refreshTokenExpiryDate!.toIso8601String(),
//           'accessToken': accessToken,
//           'accessTokenExpiry': accessTokenExpiryDate!.toIso8601String()
//         });
//         prefs.setString('userData', userData);
//         loading(false);
//         notifyListeners();
//     }

//     return accessToken!;
//   }

//   Future<void> registerWithPhoneNumber(
//       String smsCode,
//       BuildContext context,
//       String phoneNumber,
//       String description,
//       String languages,
//       String userName,
//       ScaffoldMessengerState scaffoldKey,
//       List prices) async {
//     final prefs = await SharedPreferences.getInstance();

//     verificationId = prefs.getString('verificationid');
//     var authentication =
//         Provider.of<AuthenticationDetails>(context, listen: false);
//     var apiCalls = Provider.of<ApiCalls>(context, listen: false);

//     try {
//       loading(true);
//       AuthCredential credential = PhoneAuthProvider.credential(
//           verificationId: verificationId!, smsCode: smsCode);

//       await auth.signInWithCredential(credential).then((value) async {
//         if (value.user != null) {
//           print('$phoneNumber');
//           await apiCalls
//               .register(phoneNumber, description, languages, userName, context,
//                   prices)
//               .then((response) async {
//             switch (response) {
//               case 400:
//                 loading(false);
//                 scaffoldKey.showSnackBar(SnackBar(
//                   content: Text('${authentication.messages}'),
//                   duration: const Duration(seconds: 5),
//                 ));
//                 break;
//               case 201:
//                 loading(false);
//                 scaffoldKey.showSnackBar(SnackBar(
//                   content: Text('${authentication.messages}'),
//                   duration: const Duration(seconds: 5),
//                 ));
//                 authentication.logout().then((value) => Navigator.of(context)
//                     .pushNamedAndRemoveUntil(
//                         '/', (Route<dynamic> route) => false));
//             }
//           });
//         }
//         loading(false);
//       });

//       notifyListeners();
//     } catch (e) {
//       loading(false);
//     }
//   }
// }
