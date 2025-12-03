import 'package:red_carga/features/shared/domain/driver.dart';

abstract class DriverRepository {
  Future<Driver> getDriverById({
    required int driverId,
    required String accessToken,
  });
}