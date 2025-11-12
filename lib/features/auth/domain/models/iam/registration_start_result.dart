import '../value/email.dart';

class RegistrationStartResult {
  final int accountId;
  final int signupIntentId;
  final Email email;
  final bool emailVerified;
  final String verificationLink;

  RegistrationStartResult({
    required this.accountId,
    required this.signupIntentId,
    required this.email,
    required this.emailVerified,
    required this.verificationLink,
  });
}

