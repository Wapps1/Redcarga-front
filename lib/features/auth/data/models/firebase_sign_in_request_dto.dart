class FirebaseSignInRequestDto {
  final String email;
  final String password;
  final bool returnSecureToken;

  FirebaseSignInRequestDto({
    required this.email,
    required this.password,
    this.returnSecureToken = true,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'returnSecureToken': returnSecureToken,
      };
}


