import 'package:red_carga/features/driver/domain/driver_profile_repository.dart';
import 'package:red_carga/features/shared/domain/driver.dart';

import 'driver_profile_service.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverService service;

  DriverRepositoryImpl({required this.service});

  @override
  Future<Driver> getDriverById({
    required int driverId,
    required String accessToken,
  }) async {
    final json = await service.getDriverById(
      driverId: driverId,
      accessToken: accessToken,
    );
    return Driver.fromJson(json);
  }
}