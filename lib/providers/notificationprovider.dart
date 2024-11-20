
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Notification extends StateNotifier {
  Notification() : super(null);
  // Future<String?> retrieveFCMTokenForUser(String userId) async {
  //   final ref = FirebaseDatabase.instance.ref();
  //   final snapshot = await ref.child('users/$userId/fcmToken').get();

  //   if (snapshot.exists) {
  //     return snapshot.value as String?;
  //   } else {
  //     print('No FCM Token available for user $userId');
  //     return null;
  //   }
  // }
  Future<String?> retrieveFCMTokenForUser(String userId) async {
    try {
      final ref = FirebaseDatabase.instance.ref();
      final tokenPath = 'users/$userId/fcmToken';
      print('Retrieving FCM token for user at path: $tokenPath');

      final snapshot = await ref.child(tokenPath).get();
      final userRef = ref.child('users').child('fcmToken').get();
      print(userRef);
      if (snapshot.exists) {
        print('FCM Token found: ${snapshot.value}');
        return snapshot.value as String?;
      } else {
        print('No FCM Token available for user $userId');
        return null;
      }
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.message}');
      return null;
    } catch (e) {
      print('General Exception: $e');
      return null;
    }
  }

  // Future<void> sendFCMMessage(
  //     String fcmToken, String title, String body) async {
  //   const String serverToken =
  //       'AAAAXyHcsjw:APA91bFnaXPqrig9QdNe7NQIbrB7qoRkrG-gjTUGWDPGW_7J5vpYMhD8zLS-Q_CYkhw1zwvThJ4MXDFsvKTsoUpVZik_9-rTRVhd_GJVeDC5KMj2qFZvDc9YfzkKnvmrTPie2anmLqm7';
  //   const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  //   final response = await http.post(
  //     Uri.parse(fcmUrl),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$serverToken',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'notification': <String, dynamic>{
  //           'title': title,
  //           'body': body,
  //           'sound': 'purohithulu_incoming_call',
  //         },
  //         'to': fcmToken,
  //       },
  //     ),
  //   );

  //   if (response.statusCode == 200) {
  //     print('FCM request for device sent successfully');
  //   } else {
  //     print(
  //         'FCM request for device failed with status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //   }
  // }
}

var notificationProvider = StateNotifierProvider((ref) => Notification());
