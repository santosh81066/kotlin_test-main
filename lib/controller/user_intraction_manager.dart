import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../providers/authnotifier.dart';

class UserInteractionManager with ChangeNotifier {
  final AuthNotifier authNotifier;
  UserInteractionManager(this.authNotifier) : super();
  TimeOfDay? selectedTimeOfBirth;
  DateTime? dateAndTimeOfBirth;
  String? dateOfBirth;
  final ImagePicker _picker = ImagePicker();
  Future<void> selectTimeOfBirth(BuildContext context) async {
    await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      if (value == null) {
        return;
      }
      selectedTimeOfBirth = value;

      //time = DateFormat('HH:mm').format(selectedTime).toString();
    });
    // print(
    //     '${date} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}');
  }

  Future<XFile?> onImageButtonPress(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 30);
      return pickedFile;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  String generateRandomLetters(int length) {
    var random = Random();
    var letters = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(letters);
  }

  Future<void> dateofbirth(BuildContext context) async {
    await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1880, 3, 1),
            lastDate: DateTime.now())
        .then((value) {
      if (value == null) {
        return;
      }

      dateAndTimeOfBirth = value;
      dateOfBirth =
          DateFormat('dd/MM/yyyy').format(dateAndTimeOfBirth!).toString();
    });
  }
}

final userInteractionManagerProvider = ChangeNotifierProvider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return UserInteractionManager(authNotifier);
});
