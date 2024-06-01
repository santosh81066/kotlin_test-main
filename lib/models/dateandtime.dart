import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateAndTime {
  DateTime? dateTime;
  String? date;
  TimeOfDay? selectedTime;
  String? time;

  DateAndTime({this.dateTime, this.selectedTime}) {
    if (dateTime != null) {
      date = DateFormat('dd/MM/yyyy').format(dateTime!);
    }
    if (selectedTime != null) {
      time = formatTimeOfDay(selectedTime!);
    }
  }
  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
