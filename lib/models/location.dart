class Location {
  Location({
    required this.statusCode,
    required this.success,
    required this.messages,
    required this.data,
  });
  late final int statusCode;
  late final bool success;
  late final List<String> messages;
  late final List<Data> data;

  Location.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = List.castFrom<dynamic, String>(json['messages']);
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
  }
  Location.initial()
      : this(
          statusCode: 0, // default value
          success: false, // default value
          messages: [], // default value
          data: [], // default value
        );
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {}; // renamed variable
    jsonData['statusCode'] = statusCode;
    jsonData['success'] = success;
    jsonData['messages'] = messages;
    jsonData['data'] = data.map((e) => e.toJson()).toList();
    return jsonData; // return the renamed variable
  }

  Location copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return Location(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }
}

class Data {
  Data({
    required this.id,
    required this.location,
  });
  late final int id;
  late final String location;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['location'] = location;
    return data;
  }
}
