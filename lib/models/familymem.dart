class FamilyMembers {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<FamilyMember>? data;

  FamilyMembers({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  FamilyMembers.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = (json['messages'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        data = (json['data'] as List?)
            ?.map(
                (dynamic e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((e) => e.toJson()).toList()
      };
}

class FamilyMember {
  final int? id;
  final int? userid;
  final String? familymember;

  FamilyMember({
    this.id,
    this.userid,
    this.familymember,
  });

  FamilyMember.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        userid = json['userid'] as int?,
        familymember = json['family_member'] as String?;

  Map<String, dynamic> toJson() => {
        'family_member': familymember,
      };
}
