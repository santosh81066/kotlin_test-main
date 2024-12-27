class Reports {
  String? apiId;
  String? message;
  String? success;
  Call? call;

  Reports({this.apiId, this.message, this.success, this.call});

  Reports.fromJson(Map<String, dynamic> json) {
    apiId = json['ApiId'];
    message = json['Message'];
    success = json['Success'];
    call = json['Call'] != null ? new Call.fromJson(json['Call']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ApiId'] = this.apiId;
    data['Message'] = this.message;
    data['Success'] = this.success;
    if (this.call != null) {
      data['Call'] = this.call!.toJson();
    }
    return data;
  }
}

class Call {
  String? number;
  String? callerId;
  String? callUUID;
  String? status;
  String? ringTime;
  String? answerTime;
  String? endTime;
  String? endReason;
  String? direction;
  String? pulse;
  String? pulses;
  String? pricePerPulse;
  String? cost;

  Call(
      {this.number,
      this.callerId,
      this.callUUID,
      this.status,
      this.ringTime,
      this.answerTime,
      this.endTime,
      this.endReason,
      this.direction,
      this.pulse,
      this.pulses,
      this.pricePerPulse,
      this.cost});

  Call.fromJson(Map<String, dynamic> json) {
    number = json['Number'];
    callerId = json['CallerId'];
    callUUID = json['CallUUID'];
    status = json['Status'];
    ringTime = json['RingTime'];
    answerTime = json['AnswerTime'];
    endTime = json['EndTime'];
    endReason = json['EndReason'];
    direction = json['Direction'];
    pulse = json['Pulse'];
    pulses = json['Pulses'];
    pricePerPulse = json['PricePerPulse'];
    cost = json['Cost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Number'] = this.number;
    data['CallerId'] = this.callerId;
    data['CallUUID'] = this.callUUID;
    data['Status'] = this.status;
    data['RingTime'] = this.ringTime;
    data['AnswerTime'] = this.answerTime;
    data['EndTime'] = this.endTime;
    data['EndReason'] = this.endReason;
    data['Direction'] = this.direction;
    data['Pulse'] = this.pulse;
    data['Pulses'] = this.pulses;
    data['PricePerPulse'] = this.pricePerPulse;
    data['Cost'] = this.cost;
    return data;
  }
}
