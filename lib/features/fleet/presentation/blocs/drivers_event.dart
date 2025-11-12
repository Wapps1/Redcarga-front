import 'dart:io';

abstract class DriversEvent {}

class LoadDrivers extends DriversEvent {
  final int companyId;
  LoadDrivers(this.companyId);
}

class CreateDriver extends DriversEvent {
  final int companyId;
  final String name;
  final String dni;
  final String phone;
  final File? licenseImage;
  CreateDriver({
    required this.companyId,
    required this.name,
    required this.dni,
    required this.phone,
    this.licenseImage,
  });
}

class UpdateDriver extends DriversEvent {
  final int driverId;
  final Map<String, dynamic> payload;
  UpdateDriver({required this.driverId, required this.payload});
}

class DeleteDriver extends DriversEvent {
  final int driverId;
  DeleteDriver(this.driverId);
}
