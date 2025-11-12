abstract class VehiclesEvent {}

class LoadVehicles extends VehiclesEvent {
  final int companyId;
  LoadVehicles(this.companyId);
}

class CreateVehicle extends VehiclesEvent {
  final int companyId;
  final String name;
  final String plate;
  CreateVehicle({required this.companyId, required this.name, required this.plate});
}

class UpdateVehicle extends VehiclesEvent {
  final int vehicleId;
  final Map<String, dynamic> payload;
  UpdateVehicle({required this.vehicleId, required this.payload});
}

class DeleteVehicle extends VehiclesEvent {
  final int vehicleId;
  DeleteVehicle(this.vehicleId);
}
