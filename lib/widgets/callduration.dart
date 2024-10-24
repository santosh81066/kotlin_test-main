import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../providers/bookingnotifier.dart';
import '../providers/zegeocloudprovider.dart';

class CallDurationWidget extends StatelessWidget {
  const CallDurationWidget({Key? key}) : super(key: key);

  static DateTime callStartTime = DateTime.now();
  static ValueNotifier<DateTime> timeListenable =
      ValueNotifier<DateTime>(DateTime.now());
  static ValueNotifier<bool> shouldEndCall = ValueNotifier<bool>(false);

  static Timer? timer;
  static double? costPerSecond;
  static void stopTimer(BuildContext context, WidgetRef ref) {
    var callDetails = ref.read(bookingDataProvider.notifier);
    var purohithDetails = ref.read(zegeoCloudNotifierProvider);
    print('purohith details :${purohithDetails.purohithId.toString()}');
    // final ff = Provider.of<FlutterFunctions>(context, listen: false);
    timer?.cancel();
    timer = null;
    if (costPerSecond != null) {
      final duration = DateTime.now().difference(callStartTime);
      final durationText = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      var callCost = (duration.inSeconds * costPerSecond!);

      callCost = callCost / 1.1;

      // ff.setAmount(callCost);
      double formattedTime = durationText + (seconds / 100);

      BookingData newBooking = BookingData(
        // Set properties for the new booking
        amount: callCost,
        minutes: formattedTime,
        // ... other properties ...
      );

      callDetails.sendBooking(
          context: context,
          ctypeId: purohithDetails.ctypeId.toString(),
          purohithId: purohithDetails.purohithId.toString(),
          bookings: newBooking);
    }
    Navigator.pop(context);
  }

  static void startTimer(double callRate, BuildContext context,
      String billingMode, WidgetRef ref) {
    final fbuser = FirebaseAuth.instance.currentUser;
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference userWalletRef =
        database.ref().child('wallet').child(fbuser!.uid);
    callRate = callRate * 1.1;
    print('call rate: $callRate');
    costPerSecond = callRate / 20 / 60;
    print("costPerSecond: $costPerSecond");
    timer?.cancel();
    callStartTime = DateTime.now();
    timeListenable.value = callStartTime;
    userWalletRef.once().then((DatabaseEvent event) {
      double walletBalance =
          ((event.snapshot.value as Map<dynamic, dynamic>)['amount'] as num)
              .toDouble();
      double? previousWalletBalance;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        timeListenable.value = DateTime.now();
        final duration = timeListenable.value.difference(callStartTime);
        walletBalance -= costPerSecond!;
        print("wallet Balence: $walletBalance");
        if (previousWalletBalance != null) {
          double difference = walletBalance - previousWalletBalance!;
          print('Difference added this second: $difference');
        }
        previousWalletBalance = walletBalance;
        await userWalletRef.update({'amount': walletBalance});
        // Check if walletBalance <= 0 or call duration reaches 20 mins
        if ((billingMode == 'p' &&
                (walletBalance <= 0 || duration.inMinutes >= 20)) ||
            (billingMode == 'f' && duration.inMinutes >= 20)) {
          // This block will run if:
          // 1. billingMode is 'p' and either walletBalance is 0 (or negative) or duration is 20 minutes or more
          // 2. OR if billingMode is 'f' and duration is 20 minutes or more

          if (walletBalance <= 0) {
            stopTimer(context, ref);
            Navigator.of(context).pop();
          }

          // If you need to handle the scenario when duration reaches 20 minutes, you can add an else if block here.
          // else if (duration.inMinutes >= 20) {
          //     // Your logic for when the call reaches 20 minutes
          // }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CallDurationWidget.timeListenable,
      builder: (context, DateTime currentTime, _) {
        final duration =
            currentTime.difference(CallDurationWidget.callStartTime);
        final durationText = duration.toText();
        debugPrint(durationText);
        return Stack(
          children: [
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  durationText,
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

extension DurationToText on Duration {
  String toText() {
    var microseconds = inMicroseconds;
    var hours = (microseconds ~/ Duration.microsecondsPerHour).abs();
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);
    if (microseconds < 0) microseconds = -microseconds;
    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var minutesPadding = minutes < 10 ? "0" : "";
    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var secondsPadding = seconds < 10 ? "0" : "";
    return '$hours:$minutesPadding$minutes:$secondsPadding$seconds';
  }
}
