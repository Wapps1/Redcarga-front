import '../../domain/repositories/auth_remote_repository.dart';
import '../../domain/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/identity_remote_repository.dart';
import '../../domain/repositories/provider_remote_repository.dart';
import '../repositories/auth_remote_repository_impl.dart';
import '../repositories/firebase_auth_repository_impl.dart';
import '../repositories/identity_remote_repository_impl.dart';
import '../repositories/provider_remote_repository_impl.dart';
import '../services/auth_service.dart';
import '../services/identity_service.dart';
import '../services/provider_service.dart';

class AuthRepositories {
  static final FirebaseAuthRepository _firebaseRepo = FirebaseAuthRepositoryImpl();

  static AuthRemoteRepository createAuthRemoteRepository() {
    return AuthRemoteRepositoryImpl(
      authService: AuthService(),
      getFirebaseIdToken: () async {
        final token = await _firebaseRepo.getCurrentIdToken();
        if (token == null) {
          throw Exception('No Firebase token available');
        }
        return token;
      },
    );
  }

  static FirebaseAuthRepository createFirebaseAuthRepository() {
    return _firebaseRepo;
  }

  static IdentityRemoteRepository createIdentityRemoteRepository() {
    return IdentityRemoteRepositoryImpl(
      identityService: IdentityService(),
      getFirebaseIdToken: () async {
        final token = await _firebaseRepo.getCurrentIdToken();
        if (token == null) {
          throw Exception('No Firebase token available');
        }
        return token;
      },
    );
  }

  static ProviderRemoteRepository createProviderRemoteRepository() {
    return ProviderRemoteRepositoryImpl(
      providerService: ProviderService(),
      getFirebaseIdToken: () async {
        final token = await _firebaseRepo.getCurrentIdToken();
        if (token == null) {
          throw Exception('No Firebase token available');
        }
        return token;
      },
    );
  }
}

