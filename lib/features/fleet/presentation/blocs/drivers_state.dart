import 'package:red_carga/features/fleet/domain/driver.dart';

enum DriversStatus { initial, loading, success, failure }

class DriversState {
  final DriversStatus status;
  final List<Driver> drivers;
  final String? message;
  final int? companyId;
  final bool submitting; // true durante create/update/delete

  const DriversState({
    this.status = DriversStatus.initial,
    this.drivers = const [],
    this.message,
    this.companyId,
    this.submitting = false,
  });

  DriversState copyWith({
    DriversStatus? status,
    List<Driver>? drivers,
    String? message,
    int? companyId,
    bool? submitting,
  }) {
    return DriversState(
      status: status ?? this.status,
      drivers: drivers ?? this.drivers,
      message: message,
      companyId: companyId ?? this.companyId,
      submitting: submitting ?? this.submitting,
    );
  }
}
