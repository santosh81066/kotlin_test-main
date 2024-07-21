import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';
import 'loader.dart';

class BookingNotifier extends StateNotifier<Bookings> {
  final AuthNotifier authNotifier;
  BookingNotifier(this.authNotifier) : super(Bookings());

  Future<void> getBookingHistory({BuildContext? cont}) async {
    final url = PurohitApi().baseUrl + PurohitApi().bookingHistory;
    final token = authNotifier.state.accessToken;
    print('actoken : $token');
    final databaseReference = FirebaseDatabase.instance.ref();
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;
    final client = RetryClient(
      http.Client(),
      retries: 4,
      when: (response) {
        return response.statusCode == 401 ? true : false;
      },
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          var accessToken = await authNotifier.restoreAccessToken();
          req.headers['Authorization'] = accessToken;
        }
      },
    );
    var response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token!
      },
    );
    Map<String, dynamic> bookings = json.decode(response.body);
    state = Bookings.fromJson(bookings);
    print('from booking response : $bookings');
  }

  Future<int> deleteBooking(BuildContext context, int bookingId) async {
    final url = '${PurohitApi().baseUrl}${PurohitApi().bookingHistory}';
    final databaseReference = FirebaseDatabase.instance.ref();
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;
    final token = authNotifier.state.accessToken;
    int statusCode = 0;

    final client = RetryClient(
      http.Client(),
      retries: 4,
      when: (response) {
        return response.statusCode == 401;
      },
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          var accessToken = await authNotifier.restoreAccessToken();
          req.headers['Authorization'] = accessToken;
        }
      },
    );

    try {
      var response = await client.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!,
        },
        body: json.encode({
          "bookingId": bookingId,
        }),
      );

      print('deleteBooking response: ${response.body}');
      print('Response Status Code: ${response.statusCode}');

      statusCode = response.statusCode;
      if (response.statusCode == 201) {
        final bookingRef = databaseReference.child('bookings').child(uid!);
        DataSnapshot snapshot = await bookingRef.get();

        if (snapshot.value != null) {
          if (snapshot.value is Map<dynamic, dynamic>) {
            Map<String, dynamic> bookings =
                Map<String, dynamic>.from(snapshot.value as Map);
            for (String key in bookings.keys) {
              if (bookings[key]['id'] == bookingId) {
                await bookingRef.child(key).remove();
                // Remove the booking from the local state
                state.bookingData!
                    .removeWhere((booking) => booking.id == bookingId);
                // state = Bookings(
                //   bookingData: List.from(state
                //       .bookingData!??[]), // Create a new instance to notify listeners
                // );
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Booking'),
                      content:
                          const Text('Booking has been deleted successfully'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                break;
              }
            }
          }
        }
      } else {
        print('Failed to delete booking: ${response.statusCode}');
        // Handle error response
      }
    } catch (e) {
      print('Error deleting booking: $e');
      // Handle exception
    } finally {
      client.close();
    }
    return statusCode;
  }

  Future<void> sendBooking(
      {BuildContext? context,
      String? ctypeId,
      String? purohithId,
      BookingData? bookings,
      bool? otp,
      WidgetRef? ref}) async {
    int? startOtp;
    int? endOtp;
    final loadingState = ref!.read(loadingProvider.notifier);
    loadingState.state = true;
    if (otp == true) {
      startOtp = generateRandomNumber();
      endOtp = generateRandomNumber();
      bookings = bookings!.copyWith(startotp: startOtp, endotp: endOtp);
    }
    print('booking status:${bookings!.bookingStatus}');
    final url =
        '${PurohitApi().baseUrl}${PurohitApi().catId}${ctypeId.toString()}';
    final token = authNotifier.state.accessToken;
    print('booking url : $url,body:${bookings.toJson()}');
    String jsonBody = json.encode(bookings.toJson());
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await authNotifier.restoreAccessToken();
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token!
          },
          body: jsonBody);

      var userDetails = json.decode(response.body);
      print('booking response:$userDetails');
      switch (response.statusCode) {
        case 201:
          loadingState.state = false;
          bookings = bookings.copyWith(
              id: int.parse(userDetails['data'][0]['id'].toString()));
          print('success');
          bool bookingExists = await _checkIfBookingExists(bookings.id);
          if (!bookingExists) {
            await _addBookingToFirebase(bookings);
            showDialog(
              context: context!,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Booking has been completed'),
                  actions: [
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            print('Booking ID already exists');
            showDialog(
              context: context!,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Booking ID already exists'),
                  actions: [
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
          break;
        case 500:
          loadingState.state = false;
          break;
        case 400:
          loadingState.state = false;
          showDialog(
            context: context!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(userDetails['messages'][0].toString()),
                actions: [
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          break;
      }
    } catch (e) {
      loadingState.state = false;
      print('booking error $e');
    }
  }

  Future<bool> _checkIfBookingExists(int? bookingId) async {
    final DatabaseReference bookingsRef =
        FirebaseDatabase.instance.ref().child('bookings');
    DataSnapshot snapshot = await bookingsRef.get();
    if (snapshot.exists) {
      for (var userBookings in snapshot.children) {
        for (var booking in userBookings.children) {
          if (booking.child('id').value == bookingId) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> _addBookingToFirebase(BookingData? booking) async {
    final DatabaseReference bookingsRef =
        FirebaseDatabase.instance.ref().child('bookings');
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null && booking != null) {
      await bookingsRef.child(user.uid).push().set(booking.toJson());
      print('Booking added to Firebase');
    }
  }

  int generateRandomNumber() {
    var random = Random();
    return random.nextInt(9000) + 1000;
  }
}

final bookingDataProvider =
    StateNotifierProvider<BookingNotifier, Bookings>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return BookingNotifier(authNotifier);
});
