import 'package:red_carga/features/fleet/domain/vehicle.dart';

enum VehiclesStatus { initial, loading, success, failure }

class VehiclesState {
  final VehiclesStatus status;
  final List<Vehicle> vehicles;
  final String? message;
  final int? companyId;
  final bool submitting;

  const VehiclesState({
    this.status = VehiclesStatus.initial,
    this.vehicles = const [],
    this.message,
    this.companyId,
    this.submitting = false,
  });

  VehiclesState copyWith({
    VehiclesStatus? status,
    List<Vehicle>? vehicles,
    String? message,
    int? companyId,
    bool? submitting,
  }) {
    return VehiclesState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      message: message,
      companyId: companyId ?? this.companyId,
      submitting: submitting ?? this.submitting,
    );
  }
}
