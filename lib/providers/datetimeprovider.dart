import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dateandtime.dart';

final dateAndTimeProvider =
    StateNotifierProvider<DateAndTimeNotifier, DateAndTime>((ref) {
  return DateAndTimeNotifier();
});

class DateAndTimeNotifier extends StateNotifier<DateAndTime> {
  DateAndTimeNotifier() : super(DateAndTime());

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(9999),
    );
    if (pickedDate != null) {
      state =
          DateAndTime(dateTime: pickedDate, selectedTime: state.selectedTime);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      state = DateAndTime(dateTime: state.dateTime, selectedTime: pickedTime);
    }
  }
}
