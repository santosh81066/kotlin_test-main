import 'package:image_picker/image_picker.dart';

class Events {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<EventData>? eventdata;

  Events({
    this.statusCode,
    this.success,
    this.messages,
    this.eventdata,
  });

  Events.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = (json['messages'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        eventdata = (json['data'] as List?)
            ?.map((dynamic e) => EventData.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': eventdata?.map((e) => e.toJson()).toList()
      };
}

class EventData {
  final int? id;
  final int? amount;
  final String? dateAndTime;
  final String? eventName;
  final int? catid;
  final String? address;
  final String? description;
  XFile? _xfile;
  EventData({
    this.id,
    this.amount,
    this.dateAndTime,
    this.eventName,
    this.catid,
    this.address,
    this.description,
    XFile? xfile,
  }) : _xfile = xfile;

  EventData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        amount = json['amount'] as int?,
        dateAndTime = json['date and time'] as String?,
        eventName = json['eventName'] as String?,
        catid = json['catid'] as int?,
        address = json['address'] as String?,
        description = json['description'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date and time': dateAndTime,
        'eventName': eventName,
        'catid': catid,
        'address': address,
        'description': description
      };
  XFile? get xfile => _xfile;

  set xfile(XFile? value) {
    _xfile = value;
  }
}
