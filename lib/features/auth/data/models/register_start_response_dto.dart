class RegisterStartResponseDto {
  final int accountId;
  final int signupIntentId;
  final String email;
  final bool emailVerified;
  final String verificationLink;

  RegisterStartResponseDto({
    required this.accountId,
    required this.signupIntentId,
    required this.email,
    required this.emailVerified,
    required this.verificationLink,
  });

  factory RegisterStartResponseDto.fromJson(Map<String, dynamic> json) =>
      RegisterStartResponseDto(
        accountId: json['accountId'] as int,
        signupIntentId: json['signupIntentId'] as int,
        email: json['email'] as String,
        emailVerified: json['emailVerified'] as bool,
        verificationLink: json['verificationLink'] as String,
      );
}

