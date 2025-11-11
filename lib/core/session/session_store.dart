import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/models/session/app_session.dart';
import '../../features/auth/domain/models/firebase/firebase_session.dart';
import '../../features/auth/domain/models/value/role_code.dart';
import '../../features/auth/domain/models/value/token_type.dart';
import '../../features/auth/domain/models/value/session_status.dart';

/// Store central de autenticación
/// Fuente única de verdad para toda la app
class SessionStore {
  static const String _keyAppSessionId = 'app_sessionId';
  static const String _keyAppAccountId = 'app_accountId';
  static const String _keyAppAccessToken = 'app_accessToken';
  static const String _keyAppExpiresAt = 'app_expiresAt';
  static const String _keyAppTokenType = 'app_tokenType';
  static const String _keyAppStatus = 'app_status';
  static const String _keyAppRoles = 'app_roles_csv';
  static const String _keyAppCompanyId = 'app_companyId';
  
  static const String _keyFirebaseIdToken = 'firebase_idToken';
  static const String _keyFirebaseUid = 'firebase_uid';
  static const String _keyFirebaseEmail = 'firebase_email';
  static const String _keyFirebaseExpiresAt = 'firebase_expiresAt';

  /// Guarda la sesión de la app
  Future<void> saveAppSession(AppSession session) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_keyAppSessionId, session.sessionId);
    await prefs.setInt(_keyAppAccountId, session.accountId);
    await prefs.setString(_keyAppAccessToken, session.accessToken);
    await prefs.setInt(_keyAppExpiresAt, session.expiresAt);
    await prefs.setString(_keyAppTokenType, session.tokenType.value);
    await prefs.setString(_keyAppStatus, session.status.value);
    await prefs.setString(_keyAppRoles, session.roles.map((r) => r.value).join(','));
    
    if (session.companyId != null) {
      await prefs.setInt(_keyAppCompanyId, session.companyId!);
    } else {
      await prefs.remove(_keyAppCompanyId);
    }
    
    print('💾 [SessionStore] AppSession guardada - SessionId: ${session.sessionId}, Roles: ${session.roles.map((r) => r.value).join(", ")}');
  }

  /// Obtiene la sesión de la app
  Future<AppSession?> getAppSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    final token = prefs.getString(_keyAppAccessToken);
    if (token == null) return null;
    
    final rolesCsv = prefs.getString(_keyAppRoles) ?? '';
    final roles = rolesCsv.split(',').where((r) => r.isNotEmpty).map((r) {
      switch (r.toUpperCase()) {
        case 'CLIENT':
          return RoleCode.client;
        case 'PROVIDER':
          return RoleCode.provider;
        default:
          return RoleCode.client;
      }
    }).toList();
    
    final companyId = prefs.getInt(_keyAppCompanyId);
    
    final tokenTypeStr = prefs.getString(_keyAppTokenType) ?? 'BEARER';
    final tokenType = tokenTypeStr.toUpperCase() == 'BEARER' 
        ? TokenType.bearer 
        : TokenType.bearer;
    
    final statusStr = prefs.getString(_keyAppStatus) ?? 'ACTIVE';
    final status = statusStr.toUpperCase() == 'ACTIVE'
        ? SessionStatus.active
        : statusStr.toUpperCase() == 'REVOKED'
            ? SessionStatus.revoked
            : SessionStatus.expired;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = prefs.getInt(_keyAppExpiresAt) ?? 0;
    
    // Verificar si expiró
    if (now >= expiresAt) {
      print('⚠️ [SessionStore] AppSession expirada');
      await clearAppSession();
      return null;
    }
    
    return AppSession(
      sessionId: prefs.getInt(_keyAppSessionId) ?? 0,
      accountId: prefs.getInt(_keyAppAccountId) ?? 0,
      accessToken: token,
      expiresAt: expiresAt,
      tokenType: tokenType,
      status: status,
      roles: roles,
      companyId: companyId,
    );
  }

  /// Guarda la sesión de Firebase
  Future<void> saveFirebaseSession(FirebaseSession session) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyFirebaseIdToken, session.idToken);
    await prefs.setString(_keyFirebaseUid, session.uid);
    await prefs.setString(_keyFirebaseEmail, session.email);
    await prefs.setInt(_keyFirebaseExpiresAt, session.expiresAt);
    
    print('💾 [SessionStore] FirebaseSession guardada - UID: ${session.uid}');
  }

  /// Obtiene la sesión de Firebase
  Future<FirebaseSession?> getFirebaseSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    final idToken = prefs.getString(_keyFirebaseIdToken);
    if (idToken == null) return null;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = prefs.getInt(_keyFirebaseExpiresAt) ?? 0;
    
    // Verificar si expiró
    if (now >= expiresAt) {
      print('⚠️ [SessionStore] FirebaseSession expirada');
      await clearFirebaseSession();
      return null;
    }
    
    return FirebaseSession(
      idToken: idToken,
      uid: prefs.getString(_keyFirebaseUid) ?? '',
      email: prefs.getString(_keyFirebaseEmail) ?? '',
      expiresAt: expiresAt,
    );
  }

  /// Limpia la sesión de la app
  Future<void> clearAppSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppSessionId);
    await prefs.remove(_keyAppAccountId);
    await prefs.remove(_keyAppAccessToken);
    await prefs.remove(_keyAppExpiresAt);
    await prefs.remove(_keyAppTokenType);
    await prefs.remove(_keyAppStatus);
    await prefs.remove(_keyAppRoles);
    await prefs.remove(_keyAppCompanyId);
    print('🗑️ [SessionStore] AppSession limpiada');
  }

  /// Limpia la sesión de Firebase
  Future<void> clearFirebaseSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirebaseIdToken);
    await prefs.remove(_keyFirebaseUid);
    await prefs.remove(_keyFirebaseEmail);
    await prefs.remove(_keyFirebaseExpiresAt);
    print('🗑️ [SessionStore] FirebaseSession limpiada');
  }

  /// Limpia todas las sesiones (logout)
  Future<void> clearAll() async {
    await clearAppSession();
    await clearFirebaseSession();
    print('🗑️ [SessionStore] Todas las sesiones limpiadas');
  }
}

