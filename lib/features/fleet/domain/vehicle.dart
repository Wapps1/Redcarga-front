import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final int vehicleId;
  final String name;
  final String plate;
  final bool active;

  const Vehicle({
    required this.vehicleId,
    required this.name,
    required this.plate,
    this.active = true,
  });

  Vehicle copyWith({
    int? vehicleId,
    String? name,
    String? plate,
    bool? active,
  }) {
    return Vehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [vehicleId, name, plate, active];
}