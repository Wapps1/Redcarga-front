import '../models/value/email.dart';
import '../models/value/password.dart';
import '../models/firebase/firebase_session.dart';

abstract class FirebaseAuthRepository {
  Future<FirebaseSession> signInWithPassword(Email email, Password password);
  Future<void> signOut();
  Future<String?> getCurrentIdToken();
}
