class PurohitUsers {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  PurohitUsers({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  PurohitUsers.fromJson(Map<String, dynamic> json)
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
  final String? username;
  final int? mobileno;
  final String? profilepic;
  final int? catid;
  final String? languages;
  final String? expirience;
  final String? role;
  final int? userstatus;
  final int? isonline;
  final dynamic location;
  final int? amount;
  final double? percentage = 10.0;
  final int? _originalAmount;
  Data({
    this.id,
    this.username,
    this.mobileno,
    this.profilepic,
    this.catid,
    this.languages,
    this.expirience,
    this.role,
    this.userstatus,
    this.isonline,
    this.location,
    this.amount,
  }) : _originalAmount = amount;

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        username = json['username'] as String?,
        mobileno = json['mobileno'] as int?,
        profilepic = json['profilepic'] as String?,
        catid = json['catid'] as int?,
        languages = json['languages'] as String?,
        expirience = json['expirience'] as String?,
        role = json['role'] as String?,
        userstatus = json['userstatus'] as int?,
        isonline = json['isonline'] as int?,
        location = json['location'],
        amount = json['amount'] as int?,
        _originalAmount = json['amount'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'mobileno': mobileno,
        'profilepic': profilepic,
        'catid': catid,
        'languages': languages,
        'expirience': expirience,
        'role': role,
        'userstatus': userstatus,
        'isonline': isonline,
        'location': location,
        'amount': amount
      };

  int? getAmountWithPercentageIncrease() {
    if (_originalAmount == null || percentage == null) {
      return amount;
    }
    return (_originalAmount * (1 + percentage! / 100)).toInt();
  }
}
