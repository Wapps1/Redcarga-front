import 'package:equatable/equatable.dart';

abstract class VehiclesEvent extends Equatable {
  const VehiclesEvent();

  @override
  List<Object?> get props => [];
}

class VehiclesRequested extends VehiclesEvent {
  final int companyId;
  const VehiclesRequested(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

class VehicleCreatedRequested extends VehiclesEvent {
  final int companyId;
  final String name;
  final String plate;

  const VehicleCreatedRequested({
    required this.companyId,
    required this.name,
    required this.plate,
  });

  @override
  List<Object?> get props => [companyId, name, plate];
}