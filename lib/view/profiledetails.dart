import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../models/purohithusers.dart';
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
  void handleCallTap(BuildContext context, Data user,
       String productId) {
    
      initiateCall(context, ref, user, productId);
   
  }
  void initiateCall(BuildContext context, WidgetRef ref, Data user,
      String productId) {
    ref.read(zegeoCloudNotifierProvider.notifier).setPurohithDetails(
        user.amount?.toDouble() ?? 0.0, int.parse(productId), user.id!);
    var invites = ref
        .read(zegeoCloudNotifierProvider.notifier)
        .getInvitesFromTextCtrl(user.id.toString())
        .map((u) {
      return ZegoCallUser(u.id, user.username!);
    }).toList();
    ZegoUIKitPrebuiltCallInvitationService().send(resourceID:"purohithulu",invitees: invites, isVideoCall: false,customData: json.encode({
            "amount": user.amount ?? 0.0,
            "userid": ref.read(userProfileDataProvider).data![0].id,
            "catid": productId
          }),notificationTitle: "purohithulu",notificationMessage: "You got an incomming call");
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
    //  final handleCallTap = arguments['handleCallTap'] as Function;
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
                                    ? Button(
                                        buttonname: "Call Purohith",
                                        width: double.infinity,
                                        onTap: () {
                                          handleCallTap(context,user,productId);
                                        })
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
