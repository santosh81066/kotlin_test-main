// import 'dart:convert';
// import 'dart:io' as platform;

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/retry.dart';
// import 'package:image_picker/image_picker.dart';

// //import 'package:zego_express_engine/zego_express_engine.dart';
// import 'package:intl/intl.dart';
// import 'package:kotlin_test/models/profiledata.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http/http.dart' as http;
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// import '../utils/purohitapi.dart';
// import '../widgets/callduration.dart';
// import 'api_calls.dart';

// import 'auth.dart';

// class FlutterFunctions extends ChangeNotifier {
//   DateTime? dateTime;
//   String? date;
//   String? time;
//   TimeOfDay? selectedTime;
//   DateTime? dateAndTimeOfBirth;
//   String? dateOfBirth;
//   String? timeOfBirth;
//   TimeOfDay? selectedTimeOfBirth;
//   ProfileData? userDetails;
//   final ImagePicker _picker = ImagePicker();

//   int? purohithIndex;

//   final ValueNotifier<String> appBarTitle = ValueNotifier<String>('Home');
//   double? callRate;

//   int countdown = 45;
//   Map<String, XFile> imageFileList = {};
//   String? dateAndTime;

//   XFile? imageFile;

//   String? messages;
//   bool isloading = false;
//   bool wait = true;
//   FirebaseAuth auth = FirebaseAuth.instance;
//   waitTime() {
//     wait = !wait;
//     notifyListeners();
//   }

//   updateTimer() {
//     countdown--;

//     notifyListeners();
//   }

//   loading(bool load, {String? result}) {
//     isloading = !load;

//     notifyListeners();
//   }

//   void setdateAndTime(String dateAndTime) {
//     this.dateAndTime = dateAndTime;
//     notifyListeners();
//   }

//   void setPurohithIndex(int index) {
//     purohithIndex = index;
//     notifyListeners();
//   }

//   Future<void> pickDate(BuildContext context) async {
//     await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: DateTime.now(),
//             lastDate: DateTime.now().add(const Duration(days: 4)))
//         .then((value) {
//       if (value == null) {
//         return;
//       }

//       dateTime = value;
//       date = DateFormat('dd/MM/yyyy').format(dateTime!).toString();
//     });
//     notifyListeners();
//   }

//   Future<void> selectTime(BuildContext context) async {
//     await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     ).then((value) {
//       if (value == null) {
//         return;
//       }
//       selectedTime = value;
//       //time = DateFormat('HH:mm').format(selectedTime).toString();
//     });

//     notifyListeners();
//   }

//   Future<void> selectTimeOfBirth(BuildContext context) async {
//     await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     ).then((value) {
//       if (value == null) {
//         return;
//       }
//       selectedTimeOfBirth = value;
//       notifyListeners();
//       //time = DateFormat('HH:mm').format(selectedTime).toString();
//     });
//     // print(
//     //     '${date} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}');
//   }

//   Future<void> onImageButtonPress(
//       ImageSource source, BuildContext context) async {
//     var apicalls = Provider.of<ApiCalls>(context, listen: false);
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: source, imageQuality: 30);
//       // i want to insert picked file in xfile in data

//       if (pickedFile != null) {
//         apicalls.setImageFile(pickedFile);
//       }

//       notifyListeners();
//     } catch (e) {}
//   }

//   Future<void> dateofbirth(BuildContext context) async {
//     await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: DateTime(1880, 3, 1),
//             lastDate: DateTime.now())
//         .then((value) {
//       if (value == null) {
//         return;
//       }

//       dateAndTimeOfBirth = value;
//       dateOfBirth =
//           DateFormat('dd/MM/yyyy').format(dateAndTimeOfBirth!).toString();
//       notifyListeners();
//       print(date);
//     });
//   }

//   void onMakeCall(context, String userId, String username, String catname) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => ZegoSendCallInvitationButton(
//           isVideoCall: false, // set to false for voice call
//           invitees: [
//             ZegoUIKitUser(id: userId, name: "$username from $catname"),
//           ],
//         ),
//       ),
//     );
//   }

//   void onUserLogout() {
//     ZegoUIKitPrebuiltCallInvitationService().uninit();
//   }

//   Future<void> uploadIdentity(ImageSource source, String key,
//       {BuildContext? context}) async {
//     try {
//       print('button pressed');
//       final XFile? pickedFile = await _picker.pickImage(source: source);

//       // Add new or update existing file in the map using key
//       imageFileList[key] = pickedFile!;

//       notifyListeners();
//     } catch (e) {
//       print("$e");
//     }
//   }

//   Future<void> registerPhoneAuth(BuildContext context, String phoneNumber,
//       String description, String languages, String username, List price) async {
//     //var completer = Completer<bool>();
//     try {
//       loading(true);

//       //print(isloading);
//       await auth.verifyPhoneNumber(
//           phoneNumber: phoneNumber,
//           verificationCompleted:
//               (PhoneAuthCredential phoneAuthCredential) async {},
//           verificationFailed: (FirebaseException exception) {
//             loading(false);
//             print(isloading);
//           },
//           codeSent: (String verificationid, [int? forceresendingtoken]) async {
//             Navigator.of(context).pushNamed('registerotp', arguments: {
//               'phonenumber': phoneNumber,
//               "description": description,
//               "languages": languages,
//               "username": username,
//               "price": price
//             });
//             final prefs = await SharedPreferences.getInstance();
//             prefs.setString('verificationid', verificationid);
//             loading(false);
//             //print(isloading);
//           },
//           timeout: const Duration(seconds: 30),
//           codeAutoRetrievalTimeout: (String verificationid) {});
//       notifyListeners();
//     } catch (e) {
//       print(e);
//     }

//     //return completer.future;
//   }
// }
