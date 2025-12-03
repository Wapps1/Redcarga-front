import '../value/token_type.dart';
import '../value/session_status.dart';
import '../value/role_code.dart';

class AppSession {
  final int sessionId;
  final int accountId;
  final String accessToken;
  final int expiresAt;
  final TokenType tokenType;
  final SessionStatus status;
  final List<RoleCode> roles;
  final int? companyId;
  final List<RoleCode> companyRoles;
  final String? username;
  final String? email;

  AppSession({
    required this.sessionId,
    required this.accountId,
    required this.accessToken,
    required this.expiresAt,
    required this.tokenType,
    required this.status,
    required this.roles,
    this.companyId,
    this.companyRoles = const [],
    this.username,
    this.email,
  });
}