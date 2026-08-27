class AuthLoginResult {
  final bool isLoggedIn;
  final bool needsVerification;
  final String? username;
  final bool isEmail;

  const AuthLoginResult._({
    required this.isLoggedIn,
    required this.needsVerification,
    this.username,
    this.isEmail = false,
  });

  factory AuthLoginResult.loggedIn() {
    return const AuthLoginResult._(
      isLoggedIn: true,
      needsVerification: false,
    );
  }

  factory AuthLoginResult.notVerified({
    required String username,
    required bool isEmail,
  }) {
    return AuthLoginResult._(
      isLoggedIn: false,
      needsVerification: true,
      username: username,
      isEmail: isEmail,
    );
  }

  factory AuthLoginResult.failed() {
    return const AuthLoginResult._(
      isLoggedIn: false,
      needsVerification: false,
    );
  }
}

class AuthVerifyResult {
  final bool success;
  final int? userId;

  const AuthVerifyResult({
    required this.success,
    this.userId,
  });
}
