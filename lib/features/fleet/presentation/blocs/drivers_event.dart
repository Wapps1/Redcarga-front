// lib/features/fleet/presentation/blocs/driver/drivers_event.dart
abstract class DriversEvent {}

class DriversRequested extends DriversEvent {
  final int companyId;
  DriversRequested(this.companyId);
}

class CreateDriverRequested extends DriversEvent {
  final int companyId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String licenseNumber;

  CreateDriverRequested({
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.licenseNumber,
  });
}
