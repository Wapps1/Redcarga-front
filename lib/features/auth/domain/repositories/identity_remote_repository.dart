import '../models/identity/person_create_request.dart';
import '../models/identity/person_create_result.dart';

abstract class IdentityRemoteRepository {
  Future<PersonCreateResult> verifyAndCreatePerson(PersonCreateRequest request);
}

