import 'package:red_carga/features/fleet/domain/driver.dart';

enum DriversStatus { initial, loading, success, failure }

class DriversState {
  final DriversStatus status;
  final List<Driver> drivers;
  final String? message;
  final bool creating;

  const DriversState({
    this.status = DriversStatus.initial,
    this.drivers = const [],
    this.message,
    this.creating = false,
  });

  DriversState copyWith({
    DriversStatus? status,
    List<Driver>? drivers,
    String? message,
    bool? creating,
  }) => DriversState(
    status: status ?? this.status,
    drivers: drivers ?? this.drivers,
    message: message,
    creating: creating ?? this.creating,
  );
}
