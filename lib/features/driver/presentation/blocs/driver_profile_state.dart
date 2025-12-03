import 'package:meta/meta.dart';
import 'package:red_carga/features/shared/domain/driver.dart';

@immutable
abstract class DriverProfileState {
  const DriverProfileState();
}

class DriverProfileInitial extends DriverProfileState {
  const DriverProfileInitial();
}

class DriverProfileLoading extends DriverProfileState {
  const DriverProfileLoading();
}

class DriverProfileLoaded extends DriverProfileState {
  final String fullName;
  final String username;
  final String email;
  final String docNumber;
  final String phone;

  const DriverProfileLoaded({
    required this.fullName,
    required this.username,
    required this.email,
    required this.docNumber,
    required this.phone,
  });
}

class DriverProfileError extends DriverProfileState {
  final String message;

  const DriverProfileError(this.message);
}
