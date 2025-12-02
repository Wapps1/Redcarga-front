import '../../domain/repositories/firebase_auth_repository.dart';
import '../../domain/models/value/email.dart';
import '../../domain/models/value/password.dart';
import '../../domain/models/firebase/firebase_session.dart';
import '../services/auth_service.dart';
import '../models/firebase_sign_in_request_dto.dart';
import '../mappers/auth_mappers.dart';
import '../../../../core/session/session_store.dart';

class FirebaseAuthRepositoryImpl implements FirebaseAuthRepository {
  final AuthService _authService;
  final SessionStore _sessionStore;
  FirebaseSession? _currentSession;

  FirebaseAuthRepositoryImpl({
    AuthService? authService,
    SessionStore? sessionStore,
  })  : _authService = authService ?? AuthService(),
        _sessionStore = sessionStore ?? SessionStore();

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
      _currentSession = session;
      await _sessionStore.saveFirebaseSession(session);

      print(
        '💾 [FirebaseAuthRepositoryImpl] Sesión de Firebase guardada - UID: ${session.uid}, Token: ${session.idToken.substring(0, 20)}...',
      );

      return session;
    } catch (e) {
      throw Exception('Failed to sign in with Firebase: $e');
    }
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
    await _sessionStore.clearFirebaseSession();
  }

  @override
  Future<String?> getCurrentIdToken() async {
    _currentSession ??= await _sessionStore.getFirebaseSession();
    if (_currentSession == null) {
      print('⚠️ [FirebaseAuthRepositoryImpl] No hay sesión de Firebase guardada');
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= _currentSession!.expiresAt) {
      print('⚠️ [FirebaseAuthRepositoryImpl] Token de Firebase expirado');
      await _sessionStore.clearFirebaseSession();
      _currentSession = null;
      return null;
    }

    print('✅ [FirebaseAuthRepositoryImpl] Token de Firebase obtenido correctamente');
    return _currentSession!.idToken;
  }
}