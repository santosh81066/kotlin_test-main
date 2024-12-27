class Call {
  String? apiId;
  String? callUUID;
  String? message;
  String? success;

  Call({this.apiId, this.callUUID, this.message, this.success, required int amount, required int minutes, required int overPulseCount});

  Call.fromJson(Map<String, dynamic> json) {
    apiId = json['ApiId'];
    callUUID = json['CallUUID'];
    message = json['Message'];
    success = json['Success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ApiId'] = this.apiId;
    data['CallUUID'] = this.callUUID;
    data['Message'] = this.message;
    data['Success'] = this.success;
    return data;
  }
}
