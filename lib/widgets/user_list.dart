//linked with CatScreen

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categorynotifier.dart';
import '/providers/authnotifier.dart';
import '/providers/notificationprovider.dart';
import '/providers/userprofiledatanotifier.dart';
import '/providers/zegeocloudprovider.dart';

import '../models/purohithusers.dart';
import '../utils/purohitapi.dart';

import 'button.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class UserList extends ConsumerWidget {
  final List<Data> users;
  final DatabaseReference firebaseRealtimeUsersRef;
  final DatabaseReference firebaseRealtimeWalletRef;
  final String? uid;
  final int productId;
  final String catname;
  final String billingMode;
  final String cattype;

  const UserList(
      {Key? key,
      required this.users,
      required this.firebaseRealtimeUsersRef,
      required this.firebaseRealtimeWalletRef,
      required this.uid,
      required this.productId,
      required this.catname,
      required this.billingMode,
      required this.cattype})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Data> filteredUsers =
        users.where((purohith) => purohith.catid == productId).toList();
    final categoryNotifier = ref.read(categoryProvider.notifier);
    final categories = categoryNotifier.getFilteredCategories("e");
    final category = categories.firstWhere(
      (cat) => cat.id == productId,
    );

    return StreamBuilder(
      stream: firebaseRealtimeUsersRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        Map<dynamic, dynamic> fbValues =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredUsers.length,
          itemBuilder: (con, index) {
            Map<dynamic, dynamic>? foundValue;
            String? fcmToken;
            // Iterate through fbValues to find the value with the matching id
            for (var value in fbValues.values) {
              if (value['id'] == filteredUsers[index].id) {
                foundValue = value as Map<dynamic, dynamic>;
                break;
              }
            }

            // If the user is not found in Firebase, do not display anything
            if (foundValue == null) {
              return const SizedBox.shrink();
            }
            if (foundValue['fcm_token'] != null) {
              fcmToken = foundValue['fcm_token'];
            }
            bool isOnline = foundValue['isonline'] ?? false;
            bool incall = foundValue['inCall'] ?? false;

            return Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Set border color here
                    width: 0.5, // Set border width here
                  ),
                  borderRadius: BorderRadius.circular(
                      4.0), // Optional: if you want rounded corners
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(4.0),
                  elevation: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Consumer(
                            builder: (context, ref, child) {
                              final authNotifier = ref.watch(authProvider);
                              return CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    filteredUsers[index].profilepic != null
                                        ? NetworkImage(
                                            "${PurohitApi().baseUrl}${PurohitApi().purohithDp}${filteredUsers[index].id}",
                                            headers: {
                                              "Authorization":
                                                  authNotifier.accessToken!
                                            },
                                          )
                                        : const AssetImage('assets/icon.png')
                                            as ImageProvider<Object>,
                                // Optionally, you can add a radius or other styling properties here
                              );
                            },
                          ),
                          title: Text(filteredUsers[index].username!,
                              softWrap: true),
                          subtitle:
                              buildUserDetails(filteredUsers[index], incall),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                '₹ ${category.price ?? 0}',
                                softWrap: true,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            buildCallButton(
                                context,
                                filteredUsers[index],
                                incall,
                                isOnline,
                                productId.toString(),
                                ref,
                                fcmToken ?? '',
                                "${PurohitApi().baseUrl}${PurohitApi().purohithDp}${filteredUsers[index].id}",
                                '₹ ${category.price}',
                                cattype),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildUserDetails(Data user, bool incall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience: ${user.expirience}',
          softWrap: true,
        ),
        Text('Languages: ${user.languages}', softWrap: true),
      ],
    );
  }

  Widget buildCallButton(
      BuildContext context,
      Data user,
      bool incall,
      bool isOnline,
      String productId,
      WidgetRef ref,
      String fcmToken,
      String url,
      String amt,
      String cattype) {
    return StreamBuilder(
      stream: firebaseRealtimeWalletRef.child(uid!).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> walletSnapshot) {
        if (walletSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        // var walletData =
        //     walletSnapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
        // double walletAmount = walletData?['amount'] ?? 0.0;

        // if (!isOnline) {
        //   return const ElevatedButton(onPressed: null, child: Text('Offline'));
        // }
        // if (incall) {
        //   return const ElevatedButton(onPressed: null, child: Text('In Call'));
        // }
        return Flexible(
          flex: 2,
          child: Button(
              buttonTopMargin: 0,
              buttonBottomMargin: 7,
              buttonname: 'View Details ',
              onTap: () {
                Navigator.of(context).pushNamed('profileDetails', arguments: {
                  'url': url,
                  'amount': amt,
                  'cattype': cattype,
                  'user': user,
                  'productId': productId,
                  'mobileNo': user.mobileno
                });
              }),
        );
      },
    );
  }

  void handleCallTap(BuildContext context, WidgetRef ref, Data user,
      double walletAmount, String productId, String fcmToken) {
    if (walletAmount <= 0 && billingMode == 'p') {
      showWalletRechargeDialog(context);
    } else {
      initiateCall(context, ref, user, productId, fcmToken);
    }
  }

  void showWalletRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insufficient Wallet Balance'),
          content: const Text(
              'Your wallet balance is 0. Please add funds to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, 'wallet');
              },
              child: const Text('Add Amount',
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void initiateCall(BuildContext context, WidgetRef ref, Data user,
      String productId, String fcmToken) {
    ref.read(zegeoCloudNotifierProvider.notifier).setPurohithDetails(
        user.amount?.toDouble() ?? 0.0, int.parse(productId), user.id!);
    var invites = ref
        .read(zegeoCloudNotifierProvider.notifier)
        .getInvitesFromTextCtrl(user.id.toString())
        .map((u) {
      return ZegoCallUser(u.id, user.username!);
    }).toList();
    // ref.read(notificationProvider.notifier).sendFCMMessage(
    //     fcmToken, 'Purohithulu', 'You have a call from purohithulu');
    ref.read(zegeoCloudNotifierProvider).zegoController.sendCallInvitation(
          notificationTitle: catname,
          invitees: invites,
          customData: json.encode({
            "amount": user.amount ?? 0.0,
            "userid": ref.read(userProfileDataProvider).data![0].id,
            "catid": productId
          }),
          isVideoCall: false,
        );
  }
}
