import 'package:red_carga/features/fleet/domain/vehicle.dart';

enum VehiclesStatus { initial, loading, success, failure }

class VehiclesState {
  final VehiclesStatus status;
  final List<Vehicle> vehicles;
  final String? message;
  final bool creating;

  const VehiclesState({
    this.status = VehiclesStatus.initial,
    this.vehicles = const [],
    this.message,
    this.creating = false,
  });

  VehiclesState copyWith({
    VehiclesStatus? status,
    List<Vehicle>? vehicles,
    String? message,
    bool? creating,
  }) {
    return VehiclesState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      message: message,
      creating: creating ?? this.creating,
    );
  }
}