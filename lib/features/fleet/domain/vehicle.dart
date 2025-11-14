import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final int vehicleId;
  final String name;
  final String plate;

  const Vehicle({
    required this.vehicleId,
    required this.name,
    required this.plate,
  });

  Vehicle copyWith({
    int? vehicleId,
    String? name,
    String? plate,
  }) {
    return Vehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      plate: plate ?? this.plate,
    );
  }

  @override
  List<Object?> get props => [vehicleId, name, plate];
}
