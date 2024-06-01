// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:kotlin_test/controller/auth.dart';
// import 'package:otp_text_field/otp_field.dart';
// import 'package:otp_text_field/otp_field_style.dart';
// import 'package:provider/provider.dart';

// import '../controller/flutter_functions.dart';

// import '../widgets/button.dart';

// class RegisterVerifyOtp extends StatefulWidget {
//   final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
//   const RegisterVerifyOtp({super.key, this.scaffoldMessengerKey});
//   @override
//   State<RegisterVerifyOtp> createState() => _RegisterVerifyOtpState();
// }

// class _RegisterVerifyOtpState extends State<RegisterVerifyOtp> {
//   String? smsCode;
//   String button = 'Verify';

//   void timer() {
//     var updateTimer = Provider.of<FlutterFunctions>(context, listen: false);
//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (updateTimer.countdown == 0) {
//         updateTimer.waitTime();
//         timer.cancel();
//       } else {
//         updateTimer.updateTimer();
//       }
//     });
//   }

//   @override
//   void initState() {
//     timer();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var userDetails = ModalRoute.of(context)!.settings.arguments as Map;
//     var mobileno = userDetails['phonenumber'];

//     var description = userDetails['description'];
//     var languages = userDetails['languages'];
//     var username = userDetails['username'];
//     var prices = (userDetails['price'] ?? []) as List;
//     final ScaffoldMessengerState scaffoldKey =
//         widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Text(
//             "SMS has send to your Mobile",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Card(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15.0)),
//             elevation: 10,
//             margin: const EdgeInsets.all(30),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text("Change your Mobile Number"),
//                     )
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: OTPTextField(
//                     length: 6,
//                     width: MediaQuery.of(context).size.width,
//                     fieldWidth: MediaQuery.of(context).size.width / 8,
//                     otpFieldStyle:
//                         OtpFieldStyle(backgroundColor: Colors.black26),
//                     style: const TextStyle(fontSize: 17, color: Colors.white),
//                     textFieldAlignment: MainAxisAlignment.spaceAround,
//                     onChanged: (pin) {
//                       setState(() {
//                         smsCode = pin;
//                       });
//                     },
//                     onCompleted: (pin) {
//                       setState(() {
//                         smsCode = pin;
//                       });
//                     },
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {},
//                       child: Consumer<FlutterFunctions>(
//                         builder: (context, value, child) {
//                           return value.wait == true
//                               ? Text("Resend OTP in ${value.countdown}")
//                               : TextButton(
//                                   onPressed: () {
//                                     value.waitTime();
//                                     value.countdown = 45;
//                                     value.registerPhoneAuth(
//                                         context,
//                                         mobileno,
//                                         description,
//                                         languages,
//                                         username,
//                                         prices);
//                                     timer();
//                                   },
//                                   child: const Text("Resend OTP"));
//                         },
//                       ),
//                     )
//                   ],
//                 ),
//                 Consumer<AuthenticationDetails>(
//                   builder: (context, value, child) {
//                     return value.isloading
//                         ? const Center(
//                             child: CircularProgressIndicator(
//                                 backgroundColor: Colors.blueAccent),
//                           )
//                         : Button(
//                             buttonname: button,
//                             onTap: value.isloading
//                                 ? null
//                                 : () {
//                                     if (smsCode == null) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(const SnackBar(
//                                         duration: Duration(seconds: 5),
//                                         content: Text("Please Enter OTP "),
//                                       ));
//                                     } else {
//                                       value.registerWithPhoneNumber(
//                                           smsCode!,
//                                           context,
//                                           mobileno,
//                                           description,
//                                           languages,
//                                           username,
//                                           scaffoldKey,
//                                           prices);
//                                     }
//                                   },
//                           );
//                   },
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
