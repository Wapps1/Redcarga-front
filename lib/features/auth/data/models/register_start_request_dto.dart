class RegisterStartRequestDto {
  final String email;
  final String username;
  final String password;
  final String roleCode;
  final String platform;

  RegisterStartRequestDto({
    required this.email,
    required this.username,
    required this.password,
    required this.roleCode,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'password': password,
        'roleCode': roleCode,
        'platform': platform,
      };
}


