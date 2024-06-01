import 'package:image_picker/image_picker.dart';

class Categories {
  final int? statusCode;
  final bool? success;
  final List<dynamic>? messages;
  final List<Data>? data;

  Categories({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  Categories.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = json['messages'] as List?,
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
  final String? filename;
  final String? mimetype;
  final String? cattype;
  final String? billingMode;
  final int? price;
  final dynamic parentid;
  final List<SubCategory>? subcat;
  XFile? xfile; // Adding XFile property

  Data({
    this.id,
    this.title,
    this.filename,
    this.mimetype,
    this.cattype,
    this.billingMode,
    this.parentid,
    this.subcat,
    this.price,
    this.xfile,
  });
  Data copyWith({
    int? id,
    String? title,
    String? filename,
    String? mimetype,
    String? cattype,
    String? billingMode,
    int? price,
    dynamic parentid,
    List<SubCategory>? subcat,
    XFile? xfile,
  }) {
    return Data(
      id: id ?? this.id,
      title: title ?? this.title,
      filename: filename ?? this.filename,
      mimetype: mimetype ?? this.mimetype,
      cattype: cattype ?? this.cattype,
      billingMode: billingMode ?? this.billingMode,
      price: price??this.price,
      parentid: parentid ?? this.parentid,
      subcat: subcat ?? this.subcat,
      xfile: xfile ?? this.xfile,
    );
  }

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        filename = json['filename'] as String?,
        mimetype = json['mimetype'] as String?,
        cattype = json['cattype'] as String?,
        billingMode = json['billingMode'] as String?,
        price = json['price'] as int?,
        parentid = json['parentid'],
        subcat = (json['subcat'] as List?)
            ?.map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filename': filename,
        'mimetype': mimetype,
        'cattype': cattype,
        'billingMode': billingMode,
        'price': price,
        'parentid': parentid,
        'subcat': subcat?.map((e) => e.toJson()).toList()
      };
}

class SubCategory {
  final int? id;
  final String? title;
  final String? filename;
  final String? mimetype;
  final String? cattype;
  final String? billingMode;
  final int? price;

  final dynamic parentid;
  XFile? xfile; // Adding XFile property

  SubCategory({
    this.id,
    this.title,
    this.filename,
    this.mimetype,
    this.cattype,
    this.billingMode,
    this.price,
    this.parentid,
    this.xfile,
  });

  SubCategory.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        filename = json['filename'] as String?,
        mimetype = json['mimetype'] as String?,
        cattype = json['cattype'] as String?,
        billingMode = json['billingMode'] as String?,
        price = json['price'] as int?,
        parentid = json['parentid'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filename': filename,
        'mimetype': mimetype,
        'cattype': cattype,
        'billingMode': billingMode,
        'price': price,
        'parentid': parentid
      };
}
