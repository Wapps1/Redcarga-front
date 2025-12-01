import 'package:equatable/equatable.dart';

abstract class DriversEvent extends Equatable {
  const DriversEvent();

  @override
  List<Object?> get props => [];
}

class DriversRequested extends DriversEvent {
  final int companyId;

  const DriversRequested(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

class DriverCreationFlowReset extends DriversEvent {
  const DriverCreationFlowReset();
}

class DriverRegisterAccountRequested extends DriversEvent {
  final String email;
  final String username;
  final String password;

  const DriverRegisterAccountRequested({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}

class DriverIdentitySubmitted extends DriversEvent {
  final int accountId;
  final String fullName;
  final String docTypeCode;
  final String docNumber;
  final DateTime birthDate;
  final String phone;
  final String ruc;

  const DriverIdentitySubmitted({
    required this.accountId,
    required this.fullName,
    required this.docTypeCode,
    required this.docNumber,
    required this.birthDate,
    required this.phone,
    required this.ruc,
  });

  @override
  List<Object?> get props => [
        accountId,
        fullName,
        docTypeCode,
        docNumber,
        birthDate,
        phone,
        ruc,
      ];
}

class CreateDriverRequested extends DriversEvent {
  final int companyId;
  final int accountId;
  final String licenseNumber;
  final bool active;
  final String? plateImageUrl;

  const CreateDriverRequested({
    required this.companyId,
    required this.accountId,
    required this.licenseNumber,
    this.active = true,
    this.plateImageUrl,
  });

  @override
  List<Object?> get props =>
      [companyId, accountId, licenseNumber, active, plateImageUrl];
}