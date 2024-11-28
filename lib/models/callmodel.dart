import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class Call {
  final int amount;
  final int minutes;
  final double? callRate;
  final int? ctypeId;
  final int? purohithId;
  final ZegoUIKitPrebuiltCallController zegoController;

  Call(
      {required this.amount,
      required this.minutes,
      this.purohithId,
      this.ctypeId,
      this.callRate,
      ZegoUIKitPrebuiltCallController? controller})
      : zegoController = controller ?? ZegoUIKitPrebuiltCallController();

  Call copyWith(
      {int? amount,
      int? minutes,
      double? callRate,
      int? ctypeId,
      int? purohithId,
      ZegoUIKitPrebuiltCallController? controller}) {
    return Call(
      purohithId: purohithId ?? this.purohithId,
      ctypeId: ctypeId ?? this.ctypeId,
      callRate: callRate ?? this.callRate,
      amount: amount ?? this.amount,
      minutes: minutes ?? this.minutes,
      controller: controller ?? zegoController,
    );
  }
}
