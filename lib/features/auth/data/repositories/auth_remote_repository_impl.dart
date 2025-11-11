import '../../domain/repositories/auth_remote_repository.dart';
import '../../domain/models/iam/registration_request.dart';
import '../../domain/models/iam/registration_start_result.dart';
import '../../domain/models/session/app_login_request.dart';
import '../../domain/models/session/app_session.dart';
import '../services/auth_service.dart';
import '../mappers/auth_mappers.dart';

class AuthRemoteRepositoryImpl implements AuthRemoteRepository {
  final AuthService _authService;
  final Future<String> Function() _getFirebaseIdToken;

  AuthRemoteRepositoryImpl({
    required AuthService authService,
    required Future<String> Function() getFirebaseIdToken,
  })  : _authService = authService,
        _getFirebaseIdToken = getFirebaseIdToken;

  @override
  Future<RegistrationStartResult> registerStart(
    RegistrationRequest request,
  ) async {
    try {
      final dto = await _authService.registerStart(request.toDto());
      return dto.toDomain();
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  @override
  Future<AppSession> login(AppLoginRequest request) async {
    try {
      print('🔑 [AuthRemoteRepositoryImpl] Obteniendo token de Firebase...');
      final firebaseIdToken = await _getFirebaseIdToken();
      print('✅ [AuthRemoteRepositoryImpl] Token obtenido: ${firebaseIdToken.substring(0, 20)}...');
      print('📤 [AuthRemoteRepositoryImpl] Enviando request de login - Platform: ${request.platform.value}, IP: ${request.ip}');
      
      final dto = await _authService.login(
        request.toDto(),
        firebaseIdToken,
      );
      
      print('✅ [AuthRemoteRepositoryImpl] Login exitoso - SessionId: ${dto.sessionId}, AccountId: ${dto.accountId}');
      
      return dto.toDomain();
    } catch (e) {
      print('❌ [AuthRemoteRepositoryImpl] Error en login: $e');
      throw Exception('Failed to login: $e');
    }
  }
}

