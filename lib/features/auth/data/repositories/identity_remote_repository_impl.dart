import '../../domain/repositories/identity_remote_repository.dart';
import '../../domain/models/identity/person_create_request.dart';
import '../../domain/models/identity/person_create_result.dart';
import '../services/identity_service.dart';
import '../mappers/identity_mappers.dart';
import '../models/user_identity_dto.dart';
import '../../../../core/session/session_store.dart';

class IdentityRemoteRepositoryImpl implements IdentityRemoteRepository {
  final IdentityService _identityService;
  final Future<String> Function() _getFirebaseIdToken;

  IdentityRemoteRepositoryImpl({
    required IdentityService identityService,
    required Future<String> Function() getFirebaseIdToken,
  })  : _identityService = identityService,
        _getFirebaseIdToken = getFirebaseIdToken;

  @override
  Future<PersonCreateResult> verifyAndCreatePerson(
    PersonCreateRequest request,
  ) async {
    try {
      final firebaseIdToken = await _getFirebaseIdToken();
      final dto = await _identityService.verifyAndCreate(
        request.toDto(),
        firebaseIdToken,
      );
      return dto.toDomain();
    } catch (e) {
      throw Exception('Failed to create person: $e');
    }
  }

  /// Obtiene los datos de identidad de un usuario por su accountId
  Future<UserIdentityDto> getUserIdentity(int accountId) async {
    try {
      final sessionStore = SessionStore();
      final session = await sessionStore.getAppSession();
      if (session == null) {
        throw Exception('No hay sesión activa');
      }
      
      return await _identityService.getUserIdentity(accountId, session.accessToken);
    } catch (e) {
      print('❌ [IdentityRemoteRepositoryImpl] Error getting user identity: $e');
      rethrow;
    }
  }
}

