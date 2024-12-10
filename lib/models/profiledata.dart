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

  /// Adds a copyWith method to allow easy updates to the model.
  ProfileData copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<UserProfileData>? data,
  }) {
    return ProfileData(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
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
  late final XFile? xfile;

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
    this.xfile,
  });

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
        dateofbirth = json['dob'],
        placeofbirth = json['pob'] as String?,
        xfile = null;

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
        'dob': dateofbirth,
        'pob': placeofbirth,
      };

  /// Adds a copyWith method to allow easy updates to the model.
  UserProfileData copyWith({
    int? id,
    String? username,
    int? mobileno,
    String? profilepic,
    dynamic adhar,
    dynamic languages,
    dynamic expirience,
    String? role,
    int? userstatus,
    dynamic isonline,
    String? imageurl,
    dynamic adharno,
    dynamic location,
    dynamic dateofbirth,
    String? placeofbirth,
    XFile? xfile,
  }) {
    return UserProfileData(
      id: id ?? this.id,
      username: username ?? this.username,
      mobileno: mobileno ?? this.mobileno,
      profilepic: profilepic ?? this.profilepic,
      adhar: adhar ?? this.adhar,
      languages: languages ?? this.languages,
      expirience: expirience ?? this.expirience,
      role: role ?? this.role,
      userstatus: userstatus ?? this.userstatus,
      isonline: isonline ?? this.isonline,
      imageurl: imageurl ?? this.imageurl,
      adharno: adharno ?? this.adharno,
      location: location ?? this.location,
      dateofbirth: dateofbirth ?? this.dateofbirth,
      placeofbirth: placeofbirth ?? this.placeofbirth,
      xfile: xfile ?? this.xfile,
    );
  }
}
