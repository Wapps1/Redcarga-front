import 'package:equatable/equatable.dart';

abstract class SignUpProviderEvent extends Equatable {
  const SignUpProviderEvent();

  @override
  List<Object?> get props => [];
}

// Eventos del paso 1 (credenciales)
class SignUpProviderEmailChanged extends SignUpProviderEvent {
  final String email;
  const SignUpProviderEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class SignUpProviderUsernameChanged extends SignUpProviderEvent {
  final String username;
  const SignUpProviderUsernameChanged(this.username);
  @override
  List<Object?> get props => [username];
}

class SignUpProviderPasswordChanged extends SignUpProviderEvent {
  final String password;
  const SignUpProviderPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class SignUpProviderConfirmPasswordChanged extends SignUpProviderEvent {
  final String confirmPassword;
  const SignUpProviderConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

// Eventos del paso 3 (datos personales)
class SignUpProviderFullNameChanged extends SignUpProviderEvent {
  final String fullName;
  const SignUpProviderFullNameChanged(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

class SignUpProviderPhoneChanged extends SignUpProviderEvent {
  final String phone;
  const SignUpProviderPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class SignUpProviderBirthDateChanged extends SignUpProviderEvent {
  final String birthDate;
  const SignUpProviderBirthDateChanged(this.birthDate);
  @override
  List<Object?> get props => [birthDate];
}

class SignUpProviderDocumentTypeChanged extends SignUpProviderEvent {
  final String documentType;
  const SignUpProviderDocumentTypeChanged(this.documentType);
  @override
  List<Object?> get props => [documentType];
}

class SignUpProviderDocumentNumberChanged extends SignUpProviderEvent {
  final String documentNumber;
  const SignUpProviderDocumentNumberChanged(this.documentNumber);
  @override
  List<Object?> get props => [documentNumber];
}

class SignUpProviderRucChanged extends SignUpProviderEvent {
  final String ruc;
  const SignUpProviderRucChanged(this.ruc);
  @override
  List<Object?> get props => [ruc];
}

// Eventos del paso 4 (datos de empresa)
class SignUpProviderLegalNameChanged extends SignUpProviderEvent {
  final String legalName;
  const SignUpProviderLegalNameChanged(this.legalName);
  @override
  List<Object?> get props => [legalName];
}

class SignUpProviderCommercialNameChanged extends SignUpProviderEvent {
  final String commercialName;
  const SignUpProviderCommercialNameChanged(this.commercialName);
  @override
  List<Object?> get props => [commercialName];
}

class SignUpProviderCompanyRucChanged extends SignUpProviderEvent {
  final String companyRuc;
  const SignUpProviderCompanyRucChanged(this.companyRuc);
  @override
  List<Object?> get props => [companyRuc];
}

class SignUpProviderCompanyEmailChanged extends SignUpProviderEvent {
  final String companyEmail;
  const SignUpProviderCompanyEmailChanged(this.companyEmail);
  @override
  List<Object?> get props => [companyEmail];
}

class SignUpProviderCompanyPhoneChanged extends SignUpProviderEvent {
  final String companyPhone;
  const SignUpProviderCompanyPhoneChanged(this.companyPhone);
  @override
  List<Object?> get props => [companyPhone];
}

class SignUpProviderAddressChanged extends SignUpProviderEvent {
  final String address;
  const SignUpProviderAddressChanged(this.address);
  @override
  List<Object?> get props => [address];
}

// Acciones
class SignUpProviderRegisterStart extends SignUpProviderEvent {
  const SignUpProviderRegisterStart();
}

class SignUpProviderEmailVerified extends SignUpProviderEvent {
  const SignUpProviderEmailVerified();
}

class SignUpProviderVerifyPerson extends SignUpProviderEvent {
  const SignUpProviderVerifyPerson();
}

class SignUpProviderRegisterCompanyAndLogin extends SignUpProviderEvent {
  const SignUpProviderRegisterCompanyAndLogin();
}

class SignUpProviderBack extends SignUpProviderEvent {
  const SignUpProviderBack();
}


