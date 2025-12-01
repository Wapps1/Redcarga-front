import '../repositories/deals_repository.dart';
import '../services/deals_service.dart';
import '../../../../core/session/session_store.dart';

class DealsRepositories {
  static final SessionStore _sessionStore = SessionStore();

  static DealsRepository createDealsRepository() {
    return DealsRepository(
      dealsService: DealsService(),
      getAccessToken: () async {
        print('🔍 [DealsRepositories] Obteniendo sesión de SessionStore...');
        final session = await _sessionStore.getAppSession();
        if (session == null) {
          print('❌ [DealsRepositories] No hay sesión activa en SessionStore');
          throw Exception('No hay sesión activa');
        }
        print('✅ [DealsRepositories] Sesión obtenida - SessionId: ${session.sessionId}, AccountId: ${session.accountId}');
        print('🔑 [DealsRepositories] AccessToken: ${session.accessToken.substring(0, 20)}... (longitud: ${session.accessToken.length})');
        return session.accessToken;
      },
    );
  }
}

