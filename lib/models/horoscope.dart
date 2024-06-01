class Horoscope {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  Horoscope({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  Horoscope.fromJson(Map<String, dynamic> json)
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
  final int? userId;
  final String? title;
  final String? filename;

  Data({
    this.id,
    this.userId,
    this.title,
    this.filename,
  });

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        userId = json['userId'] as int?,
        title = json['title'] as String?,
        filename = json['filename'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'filename': filename,
      };
}
