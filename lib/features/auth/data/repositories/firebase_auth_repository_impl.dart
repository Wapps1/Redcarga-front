import '../../domain/repositories/firebase_auth_repository.dart';
import '../../domain/models/value/email.dart';
import '../../domain/models/value/password.dart';
import '../../domain/models/firebase/firebase_session.dart';
import '../services/auth_service.dart';
import '../models/firebase_sign_in_request_dto.dart';
import '../mappers/auth_mappers.dart';

/// Implementación que usa REST API de Firebase (igual que en Android)
/// No requiere el SDK de Firebase ni google-services.json
class FirebaseAuthRepositoryImpl implements FirebaseAuthRepository {
  final AuthService _authService;
  FirebaseSession? _currentSession;

  FirebaseAuthRepositoryImpl({
    AuthService? authService,
  }) : _authService = authService ?? AuthService();

  @override
  Future<FirebaseSession> signInWithPassword(
    Email email,
    Password password,
  ) async {
    try {
      final dto = await _authService.firebaseSignInWithPassword(
        FirebaseSignInRequestDto(
          email: email.value,
          password: password.value,
          returnSecureToken: true,
        ),
      );
      
      final session = dto.toDomain();
      _currentSession = session; // Guardar sesión actual
      
      print('💾 [FirebaseAuthRepositoryImpl] Sesión de Firebase guardada - UID: ${session.uid}, Token: ${session.idToken.substring(0, 20)}...');
      
      return session;
    } catch (e) {
      throw Exception('Failed to sign in with Firebase: $e');
    }
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
  }

  @override
  Future<String?> getCurrentIdToken() async {
    if (_currentSession == null) {
      print('⚠️ [FirebaseAuthRepositoryImpl] No hay sesión de Firebase guardada');
      return null;
    }
    
    // Verificar si el token expiró
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= _currentSession!.expiresAt) {
      print('⚠️ [FirebaseAuthRepositoryImpl] Token de Firebase expirado');
      // Token expirado, necesitarías refrescarlo
      // Por ahora, retornamos null
      return null;
    }
    
    print('✅ [FirebaseAuthRepositoryImpl] Token de Firebase obtenido correctamente');
    return _currentSession!.idToken;
  }
}
