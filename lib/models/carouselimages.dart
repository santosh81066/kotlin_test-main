import 'package:image_picker/image_picker.dart';

class SliderImages {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  SliderImages({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  SliderImages.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = (json['messages'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        data = (json['data'] as List?)
            ?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((e) => e.toJson()).toList()
      };
}

class Data {
  final int? id;
  final String? title;
  final String? image;
  XFile? _xfile;
  Data({
    this.id,
    this.title,
    this.image,
    XFile? xfile,
  }) : _xfile = xfile;

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        image = json['image'] as String?;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'image': image};
  XFile? get xfile => _xfile;
  set xfile(XFile? value) {
    _xfile = value;
  }
}
