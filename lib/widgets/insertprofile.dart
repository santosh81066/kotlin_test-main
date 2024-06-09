import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/flutter_functions.dart';
import '../providers/imagepicker.dart';

class InsertProfile extends ConsumerWidget {
  const InsertProfile(
      {super.key,
      this.buttonName,
      this.imageIcon,
      this.insertCategory,
      this.label,
      this.index});

  final String? buttonName;
  final String? label;
  final Function? imageIcon;
  final Function? insertCategory;
  final String? index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePickerState = ref.watch(imagePickerProvider);
    final imagePickerNotifier = ref.read(imagePickerProvider.notifier);

    return Column(
      children: [
        imagePickerState.imageFileList.containsKey(index)
            ? SizedBox(
                child: Image.file(
                    File(imagePickerState.imageFileList[index]!.path)),
              )
            : TextButton.icon(
                onPressed: () {
                  imagePickerNotifier.uploadIdentity(
                      ImageSource.gallery, index!);
                },
                icon: const Icon(Icons.image),
                label: Text(label!),
              ),
      ],
    );
  }
}
