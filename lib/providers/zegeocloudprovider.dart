// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// import '../models/callmodel.dart';
// import '../widgets/callduration.dart';
// import 'bookingnotifier.dart';

// class ZegeoCloudNotifier extends StateNotifier<Call> {
//   ZegeoCloudNotifier() : super(Call(amount: 0, minutes: 0));
//   void onUserLogin(String userId, String userName, BuildContext context,
//       String catname, String cattype, WidgetRef ref) {
//     final fbuser = FirebaseAuth.instance.currentUser;
//     final uid = fbuser?.uid;
//     var getbooking = ref.read(bookingDataProvider.notifier);
//     final userRef =
//         FirebaseDatabase.instance.ref().child('presence').child(uid.toString());
//     ZegoUIKitPrebuiltCallInvitationService().init(
//       events: ZegoUIKitPrebuiltCallEvents(
//         onCallEnd: (event, defaultAction) async {
//           CallDurationWidget.stopTimer(context, ref);
//           getbooking.getBookingHistory();
//           print(" onCallEnd stop timer:");
          
//           await userRef.update({
//             'inCall': false,

//             // Add more fields if needed
//           });
//         },
//       ),
//       // invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
//       //   onIncomingCallAcceptButtonPressed: () async {
//       //     CallDurationWidget.startTimer(state.callRate!, context, cattype, ref);
//       //     await userRef.update({
//       //       'inCall': true,

//       //       // Add more fields if needed
//       //     });
//       //   },
//       //   onIncomingCallDeclineButtonPressed: () async {
//       //     CallDurationWidget.stopTimer(context, ref);
//       //     print(" onIncomingCallDeclineButtonPressed stop timer:");
//       //     await userRef.update({
//       //       'inCall': false,

//       //       // Add more fields if needed
//       //     });
//       //   },
//       //   onOutgoingCallCancelButtonPressed: () async {
//       //     CallDurationWidget.stopTimer(context, ref);
//       //     print(" onOutgoingCallCancelButtonPressed stop timer:");
//       //     CallDurationWidget.stopTimer(context, ref);
//       //     await userRef.update({
//       //       'inCall': false,

//       //       // Add more fields if needed
//       //     });
//       //   },
//       //   // onOutgoingCallAccepted: (String callID, ZegoCallUser calee) {
//       //   //   CallDurationWidget.startTimer(state.callRate!, context, cattype, ref);
//       //   // },
//       // ),

//       appID: 1541186595,
//       appSign:
//           '9e3efd985294e0f65d9d924894e659e6604e863e5d4b93f4704c98319f5d8572',
//       userID: userId,
//       userName: "$userName($catname)",
//       plugins: [ZegoUIKitSignalingPlugin()],
//       requireConfig: (ZegoCallInvitationData data) {
//         final config = (data.invitees.length > 1)
//             ? ZegoCallType.videoCall == data.type
//                 ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
//                 : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
//             : ZegoCallType.videoCall == data.type
//                 ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
//                 : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
//         // ..durationConfig.isVisible = true
//         // ..durationConfig.onDurationUpdate = (Duration duration) {
//         //   if (duration.inSeconds >= 20 * 60) {
//         //     state.zegoController.hangUp(context);
//         //   }
//         //};
//         config.duration.isVisible = true;
//         config.duration.onDurationUpdate = (Duration duration) {
//           // if (duration.inSeconds >= 5 * 60) {
//           //   state.zegoController.hangUp(context);
//           // }
//         };

//         /// support minimizing, show minimizing button
//         config.topMenuBarConfig.isVisible = true;

//         config.audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
//           foregroundBuilder: (context, size, user, extraInfo) {
//             final screenSize = MediaQuery.of(context).size;
//             final isSmallView = size.height < screenSize.height / 2;
//             if (isSmallView) {
//               return Container();
//             } else {
//               return const CallDurationWidget();
//             }
//           },
//         );

//         return config;
//       },
//       // controller: state.zegoController
//     );
//   }

//   List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
//     final invitees = <ZegoUIKitUser>[];

//     final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
//     inviteeIDs.split(',').forEach((inviteeUserID) {
//       if (inviteeUserID.isEmpty) {
//         return;
//       }

//       invitees.add(ZegoUIKitUser(
//         id: inviteeUserID,
//         name: 'user_$inviteeUserID',
//       ));
//     });

//     return invitees;
//   }

//   // void setPurohithDetails(double? callRate, int? catid, int? purohithId) {
//   //   print('setPurohithDetails ');
//   //   state = state.copyWith(
//   //       callRate: callRate, ctypeId: catid, purohithId: purohithId);
//   //   print('setPurohithDetails ${state.callRate}');
//   // }

//   void setCallDetails() {}
// }

// var zegeoCloudNotifierProvider =
//     StateNotifierProvider<ZegeoCloudNotifier, Call>(
//         (ref) => ZegeoCloudNotifier());
