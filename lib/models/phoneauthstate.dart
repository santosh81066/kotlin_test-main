class PhoneAuthState {
  final int countdown;
  final bool wait;
  final String? verificationId; // To store Firebase verification ID

  PhoneAuthState({
    this.countdown = 45,
    this.wait = true,
    this.verificationId,
  });

  PhoneAuthState copyWith({
    int? countdown,
    bool? wait,
    String? verificationId,
  }) {
    return PhoneAuthState(
      countdown: countdown ?? this.countdown,
      wait: wait ?? this.wait,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}
