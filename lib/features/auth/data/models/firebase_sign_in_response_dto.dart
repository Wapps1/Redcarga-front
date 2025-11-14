class FirebaseSignInResponseDto {
  final String localId;
  final String email;
  final String idToken;
  final String refreshToken;
  final String expiresIn;

  FirebaseSignInResponseDto({
    required this.localId,
    required this.email,
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory FirebaseSignInResponseDto.fromJson(Map<String, dynamic> json) =>
      FirebaseSignInResponseDto(
        localId: json['localId'] as String,
        email: json['email'] as String,
        idToken: json['idToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresIn: json['expiresIn'] as String,
      );
}


