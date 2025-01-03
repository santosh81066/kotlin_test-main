import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk2purohith/providers/authnotifier.dart';
import 'package:talk2purohith/providers/makecallnotifier.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/purohithusers.dart';
import '../providers/categorynotifier.dart';
import '../providers/userprofiledatanotifier.dart';
import '../providers/zegeocloudprovider.dart';
import '../widgets/appbar.dart';
import '../widgets/button.dart';
import '../widgets/customdialogbox.dart';
import '../widgets/rowItems.dart';

class ProfileDetails extends ConsumerStatefulWidget {
  const ProfileDetails({super.key});

  @override
  ConsumerState<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  Stream<Map<String, dynamic>> combineStreams(
      Stream<DatabaseEvent> stream1, Stream<DatabaseEvent> stream2) async* {
    await for (var event1 in stream1) {
      await for (var event2 in stream2) {
        yield {
          'usersSnapshot': event1,
          'walletSnapshot': event2,
        };
      }
    }
  }

  // Called when the "Call Failed" dialog is displayed
  void showCallFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Call Failed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.error,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                "The call could not be connected. Please try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show the waitlist dialog
  void showWaitlistDialog(
      BuildContext context, String username, String purohithName) {
    Timer(Duration(seconds: 60), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return CountdownDialog(username: username);
      },
    );

    // Listen for the "Call Found" message and close the dialog
    listenForCallFoundMessage(context);
  }

  // Listen for the "Call Found" message and close the dialog
  void listenForCallFoundMessage(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      String message =
          "Call Found"; // This could come from an event or callback

      if (message == "Call Found" && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close the dialog
      }
    });
  }

   @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    print('profile details:${arguments['cattype']}');
    final user = arguments['user'] as Data;
    final productId = arguments['productId'] as String;
    final DatabaseReference firebaseRealtimeUsersRef =
        FirebaseDatabase.instance.ref().child('presence');
    final categoryNotifier = ref.read(categoryProvider.notifier);
    final categories = categoryNotifier.getFilteredCategories("e");
    final category = categories.firstWhere(
      (cat) => cat.id == int.parse(productId),
    );
    final firebaseUserId = FirebaseAuth.instance.currentUser?.uid;
    final DatabaseReference firebaseRealtimeWalletRef =
        FirebaseDatabase.instance.ref().child('wallet').child(firebaseUserId!);
    final combinedStream = combineStreams(
        firebaseRealtimeUsersRef.onValue, firebaseRealtimeWalletRef.onValue);
    //  final handleCallTap = arguments['handleCallTap'] as Function;
    print("ProfileDetails:${user.amount}");
    return Scaffold(
        appBar: purohithAppBar(context, 'Purohith Profile'),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenSize.height * 0.9),
            child: IntrinsicHeight(
              child: Center(
                child: SizedBox(
                  width: screenSize.width * 0.95,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                bottom: screenSize.height * 0.02),
                            width: screenSize.width * 0.8,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenSize.width * 0.3,
                                    height: screenSize.height * 0.3,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '${arguments['url']}'),
                                        ),
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  Text(
                                    user.username!,
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(
                                    "Purohit",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color.fromARGB(255, 75, 73, 73)),
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RowItems(
                                          icon: Icons.star, text: "4.8(1494)"),
                                      RowItems(
                                          icon: Icons.business_center_sharp,
                                          text: "10years"),
                                      RowItems(
                                          icon: Icons.groups,
                                          text: "5.4k consultants")
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.02,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Payment details:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: screenSize.height * 0.015),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Consulation Fee",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "${arguments['amount']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Proficient in:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                      bottom: screenSize.height * 0.015,
                                    ),
                                    child: const Text(
                                      "Astrology,Horoscope,Numerology",
                                      style: TextStyle(fontSize: 14),
                                    )),
                                const Text(
                                  "Sampradayalu:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: screenSize.height * 0.015),
                                  child: const Text(
                                    "Telangana,Andra pradesh",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                const Text(
                                  "About Naryana Sharma:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                // Container(
                                //   margin: EdgeInsets.only(
                                //       bottom: screenSize.height * 0.015),
                                //   child: const Text(
                                //     "i am proficient in all poojas",
                                //     style: TextStyle(fontSize: 14),
                                //   ),
                                // ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: screenSize.height * 0.015),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "I am proficient in all poojas",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          const url =
                                              'https://youtu.be/qaf4cDPsW68?si=c6eWifJA4WhGjaWL'; // Replace with your URL
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                    ),
                                  ),
                                ),
                                arguments['cattype'] == 'c'
                                    ? StreamBuilder(
                                        stream: combinedStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          }
                                          var combinedData = snapshot.data!;
                                          var usersSnapshot =
                                              combinedData['usersSnapshot'];
                                          var walletSnapshot =
                                              combinedData['walletSnapshot'];

                                          Map<dynamic, dynamic>? foundValue;
                                          Map<dynamic, dynamic> fbValues =
                                              usersSnapshot.snapshot.value
                                                  as Map<dynamic, dynamic>;
                                          for (var value in fbValues.values) {
                                            if (value['id'] == user.id) {
                                              foundValue = value as Map<dynamic,
                                                      dynamic>? ??
                                                  {};
                                              break;
                                            }
                                          }
                                          if (foundValue == null) {
                                            return const SizedBox.shrink();
                                          }
                                          bool isOnline =
                                              foundValue['isonline'] ?? false;
                                          bool incall =
                                              foundValue['inCall'] ?? false;
                                          double walletAmount = 0.0;
                                          Map<dynamic, dynamic> walletData =
                                              walletSnapshot.snapshot.value
                                                      as Map<dynamic,
                                                          dynamic>? ??
                                                  {};

                                          walletAmount =
                                              (walletData['amount'] ?? 0)
                                                  .toDouble();

                                          print(
                                              'Wallet data: ${walletSnapshot.snapshot.value}');
                                          if (!isOnline) {
                                            Data customerCare = Data(
                                                id: 168,
                                                username: "customer care");
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          // ref
                                                          //     .read(
                                                          //         makeCallNotifierProvider
                                                          //             .notifier)
                                                          //     .makeCallRequest(context,
                                                          //       ref
                                                          //           .read(
                                                          //               authProvider)
                                                          //           .mobileno
                                                          //           .toString(),
                                                          //       user.mobileno
                                                          //           .toString(),
                                                                    
                                                          //       custemor: true,
                                                          //     );
                                                         Navigator.of(context).pushNamed('Customer Care');
                                                              // showWaitlistDialog(context, ref.read(authProvider).mobileno.toString(), user.username!);
                                                        },
                                                        child: const Text(
                                                            'Call Custemor Care')),
                                                    const ElevatedButton(
                                                        onPressed: null,
                                                        child: Text('offline')),
                                                  ],
                                                ),
                                                const Text(
                                                    'Purohith is offline if it\'s urgent please contact customer care ')
                                              ],
                                            );
                                          }
                                          if (incall) {
                                            return const ElevatedButton(
                                                onPressed: null,
                                                child: Text('In Call'));
                                          }
                                          return walletAmount > 0
                                              ? Button(
                                                  buttonname: "Call Purohith",
                                                  width: double.infinity,
                                                  onTap: () {
                                                    ref
                                                        .read(
                                                            makeCallNotifierProvider
                                                                .notifier)
                                                        .makeCallRequest( context,
                                                          ref
                                                              .read(
                                                                  authProvider)
                                                              .mobileno
                                                              .toString(),
                                                          user.mobileno
                                                              .toString(),
                                                          custemor: false, 
                                                        );
                                                        showWaitlistDialog(context, ref.read(authProvider).mobileno.toString(), user.username!);
                                                    // initiateCall(
                                                    //     context,
                                                    //     ref,
                                                    //     user,
                                                    //     productId,
                                                    //     category.price == null
                                                    //         ? 0
                                                    //         : category.price!);
                                                    
                                                  })
                                              : const Text("Insuft balance");
                                        },
                                      )
                                    : Button(
                                        buttonname: "Book Purohith",
                                        width: double.infinity,
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const CustomDialogBox();
                                              });
                                        }),
                                Divider(
                                  thickness: screenSize.height * 0.006,
                                  endIndent: screenSize.width * 0.3,
                                  indent: screenSize.width * 0.3,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
// Countdown Dialog Widget - Defined outside the main widget
class CountdownDialog extends StatefulWidget {
  final String username;

  const CountdownDialog({super.key, required this.username});

  @override
  _CountdownDialogState createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<CountdownDialog> {
  int _timer = 60; // Start from 60 seconds
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Start the countdown timer
  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 1) {
        setState(() {
          _timer--;
        });
      } else {
        _countdownTimer.cancel(); // Stop the timer once it reaches 0
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close the dialog when timer reaches 0
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel(); // Cancel the timer when the dialog is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Connecting To Purohith!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.yellow[700],
                backgroundImage: const NetworkImage(
                  'https://via.placeholder.com/50', // Placeholder URL
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.username),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Time remaining: $_timer seconds",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            "You will receive a Call request when the purohith is ready",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Manually close the dialog when the button is pressed
              _countdownTimer.cancel(); // Stop the timer
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}