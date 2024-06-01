import 'package:image_picker/image_picker.dart';

class ProfileData {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<UserProfileData>? data;

  ProfileData({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  ProfileData.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = (json['messages'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        data = (json['data'] as List?)
            ?.map((dynamic e) =>
                UserProfileData.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((e) => e.toJson()).toList()
      };
  ProfileData updateUserProfile(String id, UserProfileData updatedUserProfile) {
    final updatedUsers = data ?? [];
    final userIndex = updatedUsers.indexWhere((user) => user.id == id);
    if (userIndex != -1) {
      updatedUsers[userIndex] = updatedUserProfile;
    }
    return ProfileData(
      statusCode: statusCode,
      success: success,
      messages: messages,
      data: updatedUsers,
    );
  }
}

class UserProfileData {
  final int? id;
  final String? username;
  final int? mobileno;
  final String? profilepic;
  final dynamic adhar;
  final dynamic languages;
  final dynamic expirience;
  final String? role;
  final int? userstatus;
  final dynamic isonline;
  final String? imageurl;
  final dynamic adharno;
  final dynamic location;
  final dynamic dateofbirth;
  final String? placeofbirth;
  XFile? _xfile;

  UserProfileData({
    this.id,
    this.username,
    this.mobileno,
    this.profilepic,
    this.adhar,
    this.languages,
    this.expirience,
    this.role,
    this.userstatus,
    this.isonline,
    this.imageurl,
    this.adharno,
    this.location,
    this.dateofbirth,
    this.placeofbirth,
    XFile? xfile, // add this parameter to the constructor
  }) : _xfile = xfile;

  UserProfileData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        username = json['username'] as String?,
        mobileno = json['mobileno'] as int?,
        profilepic = json['profilepic'] as String?,
        adhar = json['adhar'],
        languages = json['languages'],
        expirience = json['expirience'],
        role = json['role'] as String?,
        userstatus = json['userstatus'] as int?,
        isonline = json['isonline'],
        imageurl = json['imageurl'] as String?,
        adharno = json['adharno'],
        location = json['location'],
        dateofbirth = json['dateofbirth'],
        placeofbirth = json['placeofbirth'] as String?,
        _xfile = null; // initialize the property to null

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'mobileno': mobileno,
        'profilepic': profilepic,
        'adhar': adhar,
        'languages': languages,
        'expirience': expirience,
        'role': role,
        'userstatus': userstatus,
        'isonline': isonline,
        'imageurl': imageurl,
        'adharno': adharno,
        'location': location,
        'dateofbirth': dateofbirth,
        'placeofbirth': placeofbirth,
      };

  XFile? get xfile => _xfile;

  set xfile(XFile? value) {
    _xfile = value;
  }
}
