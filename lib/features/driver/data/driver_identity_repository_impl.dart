import 'package:red_carga/features/driver/data/driver_identity_service.dart';
import 'package:red_carga/features/driver/domain/driver_identity.dart';
import 'package:red_carga/features/driver/domain/driver_identity_repository.dart';

class DriverIdentityRepositoryImpl implements DriverIdentityRepository {
  final DriverIdentityService service;

  DriverIdentityRepositoryImpl({required this.service});

  @override
  Future<DriverIdentity> getIdentity({
    required int accountId,
    required String accessToken,
  }) async {
    final json = await service.getIdentity(
      accountId: accountId,
      accessToken: accessToken,
    );
    return DriverIdentity.fromJson(json);
  }
}