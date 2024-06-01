class AuthState {
  final int? sessionId;
  final String? accessToken;
  final DateTime? accessTokenExpiryDate;
  final String? refreshToken;
  final DateTime? refreshTokenExpiryDate;
  final int? mobileno;
  final bool profile;
  final String? ftoken;
  final String? messages;

  AuthState({
    this.messages,
    this.sessionId,
    this.accessToken,
    this.accessTokenExpiryDate,
    this.refreshToken,
    this.refreshTokenExpiryDate,
    this.mobileno,
    this.profile = false,
    this.ftoken,
  });

  // Named constructor for initializing with default values
  AuthState.initial()
      : messages = null,
        sessionId = null,
        accessToken = null,
        accessTokenExpiryDate = null,
        refreshToken = null,
        refreshTokenExpiryDate = null,
        mobileno = null,
        profile = false,
        ftoken = null;

  AuthState copyWith({
    int? sessionId,
    String? accessToken,
    DateTime? accessTokenExpiryDate,
    String? refreshToken,
    DateTime? refreshTokenExpiryDate,
    int? mobileno,
    bool? profile,
    String? ftoken,
    String? messages,
  }) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiryDate:
          accessTokenExpiryDate ?? this.accessTokenExpiryDate,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiryDate:
          refreshTokenExpiryDate ?? this.refreshTokenExpiryDate,
      mobileno: mobileno ?? this.mobileno,
      profile: profile ?? this.profile,
      ftoken: ftoken ?? this.ftoken,
      messages: messages ?? this.messages,
    );
  }
}
