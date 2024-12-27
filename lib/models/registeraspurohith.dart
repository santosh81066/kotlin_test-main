class RegisterAsPurohith {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  RegisterAsPurohith({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  RegisterAsPurohith.fromJson(Map<String, dynamic> json)
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
        'data': data?.map((e) => e.toJson()).toList(),
      };

  factory RegisterAsPurohith.initial() {
    return RegisterAsPurohith(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  RegisterAsPurohith copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return RegisterAsPurohith(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }
}

class Data {
  final int? id;
  final String? username;
  final int? mobileno;
  final dynamic profilepic;
  final dynamic adhar;
  final String? languages;
  final String? expirience;
  final String? role;
  final int? userstatus;
  final int? isonline;
  final String? imageurl;
  final dynamic adharno;
  final int? location;
  final dynamic dateofbirth;
  final String? youtubeUrl; // Add youtubeUrl field
  final dynamic placeofbirth;

  Data({
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
    this.youtubeUrl, // Add youtubeUrl to constructor
  });

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        username = json['username'] as String?,
        mobileno = json['mobileno'] as int?,
        profilepic = json['profilepic'],
        adhar = json['adhar'],
        languages = json['languages'] as String?,
        expirience = json['expirience'] as String?,
        role = json['role'] as String?,
        userstatus = json['userstatus'] as int?,
        isonline = json['isonline'] as int?,
        imageurl = json['imageurl'] as String?,
        adharno = json['adharno'],
        location = json['location'] as int?,
        dateofbirth = json['dateofbirth'],
        placeofbirth = json['placeofbirth'],
        youtubeUrl = json['youtubeUrl'] as String?; // Assign youtubeUrl

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
        'youtubeUrl': youtubeUrl, // Include youtubeUrl in toJson
      };

  Data copyWith({
    int? id,
    String? username,
    int? mobileno,
    dynamic profilepic,
    dynamic adhar,
    String? languages,
    String? expirience,
    String? role,
    int? userstatus,
    int? isonline,
    String? imageurl,
    dynamic adharno,
    int? location,
    dynamic dateofbirth,
    dynamic placeofbirth,
    String? youtubeUrl, // Add youtubeUrl to copyWith
  }) {
    return Data(
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
      youtubeUrl: youtubeUrl ?? this.youtubeUrl, // Include youtubeUrl in copyWith
    );
  }
}
