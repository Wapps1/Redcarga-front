class AppLoginResponseDto {
  final int sessionId;
  final int accountId;
  final String accessToken;
  final int expiresIn; // segundos
  final int? expiresAt; // timestamp absoluto (puede ser null si backend viejo)
  final String tokenType; // "Bearer"
  final String status; // "ACTIVE" | "REVOKED" | "EXPIRED"
  final List<String>? roles; // ["CLIENT", "PROVIDER"] (opcional por compat)
  final AccountLightDto? account; // snapshot ligero (opcional por compat)

  AppLoginResponseDto({
    required this.sessionId,
    required this.accountId,
    required this.accessToken,
    required this.expiresIn,
    this.expiresAt,
    required this.tokenType,
    required this.status,
    this.roles,
    this.account,
  });

  factory AppLoginResponseDto.fromJson(Map<String, dynamic> json) =>
      AppLoginResponseDto(
        sessionId: json['sessionId'] as int,
        accountId: json['accountId'] as int,
        accessToken: json['accessToken'] as String,
        expiresIn: json['expiresIn'] as int,
        expiresAt: json['expiresAt'] as int?,
        tokenType: json['tokenType'] as String? ?? 'Bearer',
        status: json['status'] as String? ?? 'ACTIVE',
        roles: json['roles'] != null
            ? List<String>.from(json['roles'] as List)
            : null,
        account: json['account'] != null
            ? AccountLightDto.fromJson(json['account'] as Map<String, dynamic>)
            : null,
      );
}

class AccountLightDto {
  final String username;
  final String email;
  final bool emailVerified;
  final int updatedAt;
  final int? companyId; // Solo presente para PROVIDER

  AccountLightDto({
    required this.username,
    required this.email,
    required this.emailVerified,
    required this.updatedAt,
    this.companyId,
  });

  factory AccountLightDto.fromJson(Map<String, dynamic> json) =>
      AccountLightDto(
        username: json['username'] as String,
        email: json['email'] as String,
        emailVerified: json['emailVerified'] as bool,
        updatedAt: json['updatedAt'] as int,
        companyId: json['companyId'] as int?,
      );
}

