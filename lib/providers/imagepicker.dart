import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerState {
  final Map<String, XFile> imageFileList;

  ImagePickerState({this.imageFileList = const {}});

  ImagePickerState copyWith({Map<String, XFile>? imageFileList}) {
    return ImagePickerState(imageFileList: imageFileList ?? this.imageFileList);
  }
}

class ImagePickerNotifier extends StateNotifier<ImagePickerState> {
  ImagePickerNotifier() : super(ImagePickerState());

  final ImagePicker _picker = ImagePicker();

  Future<void> uploadIdentity(ImageSource source, String key) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final newList = Map<String, XFile>.from(state.imageFileList);
        newList[key] = pickedFile;
        state = state.copyWith(imageFileList: newList);
      }
    } catch (e) {
      // Handle error
    }
  }
}

final imagePickerProvider =
    StateNotifierProvider<ImagePickerNotifier, ImagePickerState>(
  (ref) => ImagePickerNotifier(),
);
