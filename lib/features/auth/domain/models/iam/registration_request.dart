import '../value/email.dart';
import '../value/password.dart';
import '../value/username.dart';
import '../value/role_code.dart';
import '../value/platform.dart';

class RegistrationRequest {
  final Email email;
  final Username username;
  final Password password;
  final RoleCode roleCode;
  final Platform platform;

  RegistrationRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.roleCode,
    required this.platform,
  });
}


