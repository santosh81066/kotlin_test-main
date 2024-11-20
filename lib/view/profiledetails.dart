import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talk2purohith/providers/authnotifier.dart';
import 'package:talk2purohith/providers/makecallnotifier.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
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
    // Create stream controllers for both streams
    final controller1 = StreamController<DatabaseEvent>();
    final controller2 = StreamController<DatabaseEvent>();

    // Listen to the streams and add data to controllers
    stream1.listen((event) => controller1.add(event));
    stream2.listen((event) => controller2.add(event));

    // Combine the data from both streams
    await for (var event1 in controller1.stream) {
      await for (var event2 in controller2.stream) {
        yield {
          'usersSnapshot': event1,
          'walletSnapshot': event2,
        };
      }
    }
  }

  void handleCallTap(
      BuildContext context, Data user, String productId, int amount) {
    initiateCall(context, ref, user, productId, amount);
  }

  void initiateCall(BuildContext context, WidgetRef ref, Data user,
      String productId, int amount) {
    print('initiate call');
    ref
        .read(zegeoCloudNotifierProvider.notifier)
        .setPurohithDetails(amount.toDouble(), int.parse(productId), user.id!);
    var invites = ref
        .read(zegeoCloudNotifierProvider.notifier)
        .getInvitesFromTextCtrl(user.id.toString())
        .map((u) {
      return ZegoCallUser(u.id, user.username!);
    }).toList();
    ZegoUIKitPrebuiltCallInvitationService().send(
        resourceID: "purohithulu",
        invitees: invites,
        isVideoCall: false,
        customData: json.encode({
          "amount": amount,
          "userid": ref.read(userProfileDataProvider).data![0].id,
          "catid": productId
        }),
        notificationTitle: user.username,
        notificationMessage: "You got an incomming call");
    // ref.read(zegeoCloudNotifierProvider).zegoController.sendCallInvitation(
    //       notificationTitle: "catname",
    //       invitees: invites,
    // customData: json.encode({
    //   "amount": user.amount ?? 0.0,
    //   "userid": ref.read(userProfileDataProvider).data![0].id,
    //   "catid": productId
    // }),
    //       isVideoCall: false,
    //     );
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
                child: Container(
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
                                    style: TextStyle(
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
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: screenSize.height * 0.015),
                                  child: const Text(
                                    "i am proficient in all poojas",
                                    style: TextStyle(fontSize: 14),
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
                                              foundValue = value
                                              as Map<dynamic, dynamic>? ?? {};
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
                                          if (firebaseUserId != null) {
                                            Map<dynamic, dynamic> walletData =
                                                walletSnapshot.snapshot.value
                                                as Map<dynamic, dynamic>? ?? {};

                                            walletAmount =
                                                walletData['amount'] ?? 0;

                                            print(
                                                'Wallet data: ${walletSnapshot.snapshot.value}');
                                          }
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
                                                          ref
                                                              .read(
                                                                  makeCallNotifierProvider
                                                                      .notifier)
                                                              .makeCallRequest(
                                                                  ref
                                                                      .read(
                                                                          authProvider)
                                                                      .mobileno
                                                                      .toString(),
                                                                  user.mobileno
                                                                      .toString());
                                                          // handleCallTap(
                                                          //     context,
                                                          //     customerCare,
                                                          //     productId,
                                                          //     category.price!);
                                                        },
                                                        child: Text(
                                                            'Call Custemor Care')),
                                                    ElevatedButton(
                                                        onPressed: null,
                                                        child: Text('offline')),
                                                  ],
                                                ),
                                                Text(
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
                                                        .makeCallRequest(
                                                            ref
                                                                .read(
                                                                    authProvider)
                                                                .mobileno
                                                                .toString(),
                                                            user.mobileno
                                                                .toString());
                                                    // handleCallTap(
                                                    //     context,
                                                    //     user,
                                                    //     productId,
                                                    //     category.price == null
                                                    //         ? 0
                                                    //         : category.price!);
                                                  })
                                              : Text("Insuft balance");
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
