import 'package:equatable/equatable.dart';

abstract class SignUpClientEvent extends Equatable {
  const SignUpClientEvent();

  @override
  List<Object?> get props => [];
}

class SignUpClientEmailChanged extends SignUpClientEvent {
  final String email;
  const SignUpClientEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class SignUpClientUsernameChanged extends SignUpClientEvent {
  final String username;
  const SignUpClientUsernameChanged(this.username);
  @override
  List<Object?> get props => [username];
}

class SignUpClientPasswordChanged extends SignUpClientEvent {
  final String password;
  const SignUpClientPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class SignUpClientConfirmPasswordChanged extends SignUpClientEvent {
  final String confirmPassword;
  const SignUpClientConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

class SignUpClientFullNameChanged extends SignUpClientEvent {
  final String fullName;
  const SignUpClientFullNameChanged(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

class SignUpClientPhoneChanged extends SignUpClientEvent {
  final String phone;
  const SignUpClientPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class SignUpClientBirthDateChanged extends SignUpClientEvent {
  final String birthDate;
  const SignUpClientBirthDateChanged(this.birthDate);
  @override
  List<Object?> get props => [birthDate];
}

class SignUpClientDocumentTypeChanged extends SignUpClientEvent {
  final String documentType;
  const SignUpClientDocumentTypeChanged(this.documentType);
  @override
  List<Object?> get props => [documentType];
}

class SignUpClientDocumentNumberChanged extends SignUpClientEvent {
  final String documentNumber;
  const SignUpClientDocumentNumberChanged(this.documentNumber);
  @override
  List<Object?> get props => [documentNumber];
}

class SignUpClientRucChanged extends SignUpClientEvent {
  final String ruc;
  const SignUpClientRucChanged(this.ruc);
  @override
  List<Object?> get props => [ruc];
}

class SignUpClientRegisterStart extends SignUpClientEvent {
  const SignUpClientRegisterStart();
}

class SignUpClientEmailVerified extends SignUpClientEvent {
  const SignUpClientEmailVerified();
}

class SignUpClientCreatePersonAndLogin extends SignUpClientEvent {
  const SignUpClientCreatePersonAndLogin();
}

class SignUpClientBack extends SignUpClientEvent {
  const SignUpClientBack();
}


