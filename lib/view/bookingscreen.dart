import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/bookingnotifier.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  final String? title;
  final void Function(String) onTitleChanged;
  const BookingsScreen({super.key, this.title, required this.onTitleChanged});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final DatabaseReference _bookingsRef =
      FirebaseDatabase.instance.ref().child('bookings');

  void _cancelBooking(int bookingKey) {
    ref.read(bookingDataProvider.notifier).deleteBooking(context, bookingKey);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text('User not logged in'),
      );
    }
    final userBookingsRef = _bookingsRef.child(currentUser.uid);

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: StreamBuilder(
        stream: userBookingsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                'There are no bookings to show',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          Map<dynamic, dynamic> fbValues =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<Map<dynamic, dynamic>> bookings = [];
          fbValues.forEach((key, value) {
            bookings.add({
              'key': key,
              'value': value,
            });
          });

          bookings.sort((a, b) => b['value']['id'].compareTo(a['value']['id']));

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final bookingData = booking['value'];
              final bookingKey = booking['key'];
              print('Parsed booking data: $bookingData');
              print('Booking ID: ${bookingData['id']}');

              String status = "";
              String fullString = bookingData['address'] ?? '';

              String? addressPart;
              String? familyMemberPart;
              String? altMobileNoPart;
              // String? descriptionPart;

              if (fullString.isNotEmpty) {
                String processedString = fullString.startsWith('')
                    ? fullString.replaceFirst('', '')
                    : fullString;

                processedString =
                    processedString.replaceAll('familymember:', '');

                List<String> stringParts = processedString.split(',');

                if (stringParts.isNotEmpty && !stringParts[0].contains(':')) {
                  addressPart = stringParts[0].trim();
                }

                for (int i = 1; i < stringParts.length; i++) {
                  if (stringParts[i].startsWith('[')) {
                    int endIndex =
                        stringParts.indexWhere((part) => part.endsWith(']'));
                    if (endIndex != -1) {
                      familyMemberPart = stringParts
                          .sublist(i, endIndex + 1)
                          .join(',')
                          .replaceAll(RegExp(r'[\[\]]'), '')
                          .trim();
                      i = endIndex;
                    }
                  }
                }

                // Extract description part
                // if (stringParts.length > 1 && !stringParts[1].contains('[')) {
                //   descriptionPart = stringParts[1].trim();
                // }
              }

              switch (bookingData['status']) {
                case 'w':
                  status = 'Please wait while Purohith confirms booking';
                  break;
                case "o":
                  status = "Your booking is in progress";
                  break;
                case "c":
                  status = "Your booking has been completed";
                  break;
                case "a":
                  status = "Your booking has been accepted";
                  break;
                case "r":
                  status =
                      "Your booking has been rejected by Purohith, please wait while we assign you another Purohith";
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
                            'Booking ID: ${bookingData['id'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "Event Name : ${bookingData['purohit_category']?.isNotEmpty ? bookingData['purohit_category'] : ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        " ${bookingData['address']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      if (addressPart?.isNotEmpty ?? false)
                        Text(
                          'Address: $addressPart',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      // if (descriptionPart?.isNotEmpty ?? false)
                      //   Text(
                      //     'Description: $descriptionPart',
                      //     style: const TextStyle(
                      //       fontSize: 16.0,
                      //     ),
                      //   ),
                      if (bookingData['purohith_name']?.isNotEmpty ?? false)
                        Text(
                          'Purohith: ${bookingData['purohith_name']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Time: ${bookingData['time'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      if (bookingData['amount'] != null)
                        Text(
                          'Amount: ${bookingData['amount']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      if (bookingData['status'] == 'a')
                        Text(
                          'Start OTP: ${bookingData['startotp']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      if (bookingData['status'] == 'o')
                        Text(
                          'End OTP: ${bookingData['endotp']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      const SizedBox(height: 10.0),
                      bookingData['status'] == 'c'
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _cancelBooking(bookingData['id']);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../providers/bookingnotifier.dart';

// class BookingsScreen extends ConsumerStatefulWidget {
//   final String? title;
//   final void Function(String)? onTitleChanged;

//   const BookingsScreen({super.key, this.title, required this.onTitleChanged});

//   @override
//   _BookingsScreenState createState() => _BookingsScreenState();
// }

// class _BookingsScreenState extends ConsumerState<BookingsScreen> {
//   final DatabaseReference _bookingsRef =
//       FirebaseDatabase.instance.ref().child('bookings');

//   void _cancelBooking(int bookingKey) {
//     ref.read(bookingDataProvider.notifier).deleteBooking(context, bookingKey);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return const Center(
//         child: Text('User not logged in'),
//       );
//     }
//     final userBookingsRef = _bookingsRef.child(currentUser.uid);

//     return Scaffold(
//       backgroundColor: const Color(0xffF5F5F5),
//       body: StreamBuilder(
//         stream: userBookingsRef.onValue,
//         builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
//             return const Center(
//               child: Text(
//                 'There are no bookings to show',
//                 style: TextStyle(fontSize: 18.0),
//               ),
//             );
//           }

//           Map<dynamic, dynamic> fbValues =
//               snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

//           List<Map<dynamic, dynamic>> bookings = [];
//           fbValues.forEach((key, value) {
//             bookings.add({
//               'key': key,
//               'value': value,
//             });
//           });

//           bookings.sort((a, b) => b['value']['id'].compareTo(a['value']['id']));

//           return ListView.builder(
//             itemCount: bookings.length,
//             itemBuilder: (context, index) {
//               final booking = bookings[index];
//               final bookingData = booking['value'];
//               final bookingKey = booking['key'];
//               print('Parsed booking data: $bookingData');
//               print('Booking ID: ${bookingData['id']}');

//               String status = "";
//               String fullString = bookingData['address'] ?? '';

//               String? addressPart;
//               String? familyMemberPart;
//               String? altMobileNoPart;

//               if (fullString.isNotEmpty) {
//                 String processedString = fullString.startsWith('')
//                     ? fullString.replaceFirst('', '')
//                     : fullString;

//                 processedString =
//                     processedString.replaceAll('familymember:', '');

//                 List<String> stringParts = processedString.split(',');

//                 if (stringParts.isNotEmpty && !stringParts[0].contains(':')) {
//                   addressPart = stringParts[0].trim();
//                 }

//                 for (int i = 1; i < stringParts.length; i++) {
//                   if (stringParts[i].startsWith('[')) {
//                     int endIndex =
//                         stringParts.indexWhere((part) => part.endsWith(']'));
//                     if (endIndex != -1) {
//                       familyMemberPart = stringParts
//                           .sublist(i, endIndex + 1)
//                           .join(',')
//                           .replaceAll(RegExp(r'[\[\]]'), '')
//                           .trim();
//                       i = endIndex;
//                     }
//                   } else if (stringParts[i].startsWith('altmobileno:')) {
//                     altMobileNoPart = stringParts[i]
//                         .replaceFirst('altmobileno:', '')
//                         .replaceAll(RegExp(r'[\[\]]'), '')
//                         .trim();
//                   }
//                 }
//               }

//               switch (bookingData['status']) {
//                 case 'w':
//                   status = 'Please wait while Purohith confirms booking';
//                   break;
//                 case "o":
//                   status = "Your booking is in progress";
//                   break;
//                 case "c":
//                   status = "Your booking has been completed";
//                   break;
//                 case "a":
//                   status = "Your booking has been accepted";
//                   break;
//                 case "r":
//                   status =
//                       "Your booking has been rejected by Purohith, please wait while we assign you another Purohith";
//               }

//               return Container(
//                 margin: const EdgeInsets.only(bottom: 20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 20.0, horizontal: 20.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'Booking ID: ${bookingData['id'] ?? ''}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10.0),
//                       Text(
//                         "Event Name: ${bookingData['purohit_category']?.isNotEmpty ?? false ? bookingData['purohit_category'] : ''}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                         ),
//                       ),
//                       const SizedBox(height: 10.0),
//                       Text(
//                         "Description: ${bookingData['address']}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                         ),
//                       ),
//                       if (bookingData['purohith_name']?.isNotEmpty ?? false)
//                         Text(
//                           'Purohith: ${bookingData['purohith_name']}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                       const SizedBox(height: 10.0),
//                       Text(
//                         'Time: ${bookingData['time'] ?? ''}',
//                         style: const TextStyle(
//                           fontSize: 16.0,
//                         ),
//                       ),
//                       if (bookingData['amount'] != null)
//                         Text(
//                           'Amount: ${bookingData['amount']}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                       if (bookingData['status'] == 'a')
//                         Text(
//                           'Start OTP: ${bookingData['startotp']}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                       if (bookingData['status'] == 'o')
//                         Text(
//                           'End OTP: ${bookingData['endotp']}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                       const SizedBox(height: 10.0),
//                       bookingData['status'] == 'c'
//                           ? Container()
//                           : Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 TextButton(
//                                   onPressed: () {
//                                     _cancelBooking(bookingKey);
//                                   },
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: Colors.white,
//                                     backgroundColor: Colors.redAccent,
//                                   ),
//                                   child: const Text('Cancel'),
//                                 ),
//                               ],
//                             ),
//                       Text(
//                         status,
//                         style: const TextStyle(
//                           fontSize: 16.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
