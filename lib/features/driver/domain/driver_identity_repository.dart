import 'package:red_carga/features/driver/domain/driver_identity.dart';

abstract class DriverIdentityRepository {
  Future<DriverIdentity> getIdentity({
    required int accountId,
    required String accessToken,
  });
}