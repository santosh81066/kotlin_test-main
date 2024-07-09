import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';

// Add the Firebase import
import 'package:firebase_database/firebase_database.dart';

import '../providers/bookingnotifier.dart';

class BookingsScreen extends StatefulWidget {
  final String? title;
  final void Function(String) onTitleChanged;
  const BookingsScreen({super.key, this.title, required this.onTitleChanged});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // Reference to your Firebase Realtime Database
  final DatabaseReference firebaseRealtimeBookingsRef =
      FirebaseDatabase.instance.ref().child('bookings');
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('User not signed in'));
    }
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Consumer(
        builder: (cont, ref, child) {
          ref
              .watch(bookingDataProvider.notifier)
              .getBookingHistory(cont: context);
          return FutureBuilder(
            future: FirebaseDatabase.instance
                .ref()
                .child('users/${currentUser!.uid}')
                .get(),
            builder:
                (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null || snapshot.data!.value == null) {
                return const SizedBox(
                  child: Text('No Data'),
                );
              }

              Map<String, dynamic> userData =
                  Map<String, dynamic>.from(snapshot.data!.value as Map);

              // Fetch bookings with the user id
              return FutureBuilder(
                future: firebaseRealtimeBookingsRef
                    .orderByChild('userid')
                    .equalTo(userData['id'])
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DataSnapshot> bookingSnapshot) {
                  if (bookingSnapshot.hasError) {
                    return Text(
                        'Something went wrong: ${bookingSnapshot.error}');
                  }

                  if (bookingSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      !bookingSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (bookingSnapshot.data == null ||
                      bookingSnapshot.data!.value == null) {
                    return const SizedBox(
                      child: Text('No Bookings'),
                    );
                  }

                  Map<dynamic, dynamic> bookingValues =
                      bookingSnapshot.data!.value as Map<dynamic, dynamic>;

                  // Add your logic to map your Firebase data to your data model
                  List<BookingData> bookings =
                      bookingValues.values.map((value) {
                    return BookingData(
                      id: value['id'] ?? 0,
                      address: value['address'] ?? '',
                      time: value['time'] ?? '',
                      amount: value['amount'] != null
                          ? value['amount'].toDouble()
                          : 0.0,
                      minutes: value['minutes'] ?? 0,
                      userid: value['userid'] ?? 0,
                      bookingStatus: value['booking status'] ?? '',
                      startotp: value['startotp'] ?? 0,
                      endotp: value['endotp'] ?? 0,
                      purohitCategory: value['purohit_category'] ?? '',
                      familyMembers: value['familyMembers'] ?? '',
                      goutram: value['goutram'] ?? '',
                      eventName: value['event_name'] ?? '',
                      purohithName: value['purohith_name'] ?? '',
                      username: value['username'] ?? '',
                    );
                  }).toList();
                  bookings.sort((a, b) => b.id!.compareTo(a.id!));
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      print('goutram:${bookings[index].goutram!}');
                      // Your logic to display the booking information
                      String status = "";
                      String fullString = bookings[index].address!;

                      String? addressPart;
                      String? familyMemberPart;
                      String? altMobileNoPart;

                      // for address
                      if (fullString.isNotEmpty) {
                        // Remove 'address:' prefix, if it exists
                        String processedString =
                            fullString.startsWith('address:')
                                ? fullString.replaceFirst('address:', '')
                                : fullString;

                        // Keep the brackets for now
                        processedString =
                            processedString.replaceAll('familymember:', '');

                        List<String> stringParts = processedString.split(',');

                        // If the first part doesn't contain ':', it's the address
                        if (stringParts.isNotEmpty &&
                            !stringParts[0].contains(':')) {
                          addressPart = stringParts[0]
                              .trim(); // trim removes leading/trailing whitespaces
                        }

                        // Process remaining parts
                        for (int i = 1; i < stringParts.length; i++) {
                          if (stringParts[i].startsWith('[')) {
                            // Everything from '[' to the last ']' is the familyMemberPart
                            int endIndex = stringParts
                                .indexWhere((part) => part.endsWith(']'));
                            if (endIndex != -1) {
                              familyMemberPart = stringParts
                                  .sublist(i, endIndex + 1)
                                  .join(',')
                                  .replaceAll(RegExp(r'[\[\]]'), '')
                                  .trim();
                              i = endIndex; // skip processed parts
                            }
                          } else if (stringParts[i]
                              .startsWith('altmobileno:')) {
                            altMobileNoPart = stringParts[i]
                                .replaceFirst('altmobileno:', '')
                                .replaceAll(RegExp(r'[\[\]]'), '')
                                .trim();
                          }
                        }
                      }

                      switch (bookings[index].bookingStatus) {
                        case 'w':
                          status =
                              'please wait while purohith confirms booking';
                          break;
                        case "o":
                          status = "your booking is in progress";
                          break;
                        case "c":
                          status = "your booking has been completed";
                          break;
                        case "a":
                          status = "your booking has been accepted";
                          break;
                        case "r":
                          status =
                              "your booking has been rejected by purohith please wait while we assign you another purohith";
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Booking ID: ${bookings[index].id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        ' ${bookings[index].eventName == '' ? bookings[index].purohitCategory : bookings[index].eventName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child:
                                        addressPart == '' || addressPart == null
                                            ? Container()
                                            : Text(
                                                'Address: $addressPart',
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                  ),
                                  bookings[index].goutram == '' ||
                                          bookings[index].goutram == null
                                      ? Container()
                                      : Text(
                                          'Goutram: ${bookings[index].goutram}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                  bookings[index].purohithName == ''
                                      ? Container()
                                      : Text(
                                          'Purohith: ${bookings[index].purohithName}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              familyMemberPart == '' || familyMemberPart == null
                                  ? Container()
                                  : Text(
                                      'Family Members: $familyMemberPart',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                              const SizedBox(height: 10.0),
                              altMobileNoPart == '' || altMobileNoPart == null
                                  ? Container()
                                  : Text(
                                      'Alternate Mobile No: $altMobileNoPart',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                              Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                'Time: ${bookings[index].time}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              bookings[index].amount == 0.0
                                  ? Container()
                                  : Text(
                                      'Amount: ${bookings[index].amount}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                              const SizedBox(height: 10.0),
                              bookings[index].bookingStatus == 'w'
                                  ? Container()
                                  : ElevatedButton(
                                      onPressed: () {
                                        // Add your button logic here
                                      },
                                      child: const Text('Start'),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
