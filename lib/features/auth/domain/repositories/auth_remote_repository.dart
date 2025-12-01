import '../models/iam/registration_request.dart';
import '../models/iam/registration_start_result.dart';
import '../models/session/app_login_request.dart';
import '../models/session/app_session.dart';

abstract class AuthRemoteRepository {
  Future<RegistrationStartResult> registerStart(RegistrationRequest request);
  Future<AppSession> login(AppLoginRequest request);
}


