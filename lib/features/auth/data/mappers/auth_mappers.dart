import '../../domain/models/value/email.dart';
import '../../domain/models/value/token_type.dart';
import '../../domain/models/value/session_status.dart';
import '../../domain/models/value/role_code.dart';
import '../../domain/models/iam/registration_request.dart';
import '../../domain/models/iam/registration_start_result.dart';
import '../../domain/models/session/app_login_request.dart';
import '../../domain/models/session/app_session.dart';
import '../../domain/models/firebase/firebase_session.dart';
import '../models/register_start_request_dto.dart';
import '../models/register_start_response_dto.dart';
import '../models/app_login_request_dto.dart';
import '../models/app_login_response_dto.dart';
import '../models/firebase_sign_in_response_dto.dart';

extension RegistrationRequestToDto on RegistrationRequest {
  RegisterStartRequestDto toDto() {
    return RegisterStartRequestDto(
      email: email.value,
      username: username.value,
      password: password.value,
      roleCode: roleCode.value,
      platform: platform.value,
    );
  }
}

extension RegisterStartResponseDtoToDomain on RegisterStartResponseDto {
  RegistrationStartResult toDomain() {
    return RegistrationStartResult(
      accountId: accountId,
      signupIntentId: signupIntentId,
      email: Email(email),
      emailVerified: emailVerified,
      verificationLink: verificationLink,
    );
  }
}

extension AppLoginRequestToDto on AppLoginRequest {
  AppLoginRequestDto toDto() {
    print('🔄 [AppLoginRequestToDto] Convirtiendo a DTO - Platform: ${platform.value}, IP: $ip');
    return AppLoginRequestDto(
      platform: platform.value,
      ip: ip,
      ttlSeconds: ttlSeconds,
    );
  }
}

extension AppLoginResponseDtoToDomain on AppLoginResponseDto {
  AppSession toDomain() {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Mapear roles
    final rolesList = (roles ?? []).map((roleStr) {
      switch (roleStr.toUpperCase()) {
        case 'CLIENT':
          return RoleCode.client;
        case 'PROVIDER':
          return RoleCode.provider;
        default:
          return RoleCode.client;
      }
    }).toList();
    
    // Mapear tokenType
    final tokenType = this.tokenType.toUpperCase() == 'BEARER'
        ? TokenType.bearer
        : TokenType.bearer;
    
    // Mapear status
    SessionStatus sessionStatus;
    switch (this.status.toUpperCase()) {
      case 'ACTIVE':
        sessionStatus = SessionStatus.active;
        break;
      case 'REVOKED':
        sessionStatus = SessionStatus.revoked;
        break;
      case 'EXPIRED':
        sessionStatus = SessionStatus.expired;
        break;
      default:
        sessionStatus = SessionStatus.active;
    }
    
    return AppSession(
      sessionId: sessionId,
      accountId: accountId,
      accessToken: accessToken,
      expiresAt: expiresAt ?? (now + expiresIn * 1000),
      tokenType: tokenType,
      status: sessionStatus,
      roles: rolesList,
      companyId: account?.companyId,
    );
  }
}

extension FirebaseSignInResponseDtoToDomain on FirebaseSignInResponseDto {
  FirebaseSession toDomain() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = now + (int.parse(expiresIn) * 1000);
    
    return FirebaseSession(
      idToken: idToken,
      uid: localId,
      email: email,
      expiresAt: expiresAt,
    );
  }
}

