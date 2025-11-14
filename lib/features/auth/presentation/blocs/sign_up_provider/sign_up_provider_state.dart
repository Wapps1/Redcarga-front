import 'package:equatable/equatable.dart';

class SignUpProviderState extends Equatable {
  final int step;
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String verificationLink;
  final bool emailVerified;
  final int? accountId;
  final int? signupIntentId;
  final String fullName;
  final String phone;
  final String birthDate;
  final String documentType;
  final String documentNumber;
  final String ruc;
  final String legalName;
  final String commercialName;
  final String companyRuc;
  final String companyEmail;
  final String companyPhone;
  final String address;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SignUpProviderState({
    this.step = 1,
    this.email = '',
    this.username = '',
    this.password = '',
    this.confirmPassword = '',
    this.verificationLink = '',
    this.emailVerified = false,
    this.accountId,
    this.signupIntentId,
    this.fullName = '',
    this.phone = '',
    this.birthDate = '',
    this.documentType = '',
    this.documentNumber = '',
    this.ruc = '',
    this.legalName = '',
    this.commercialName = '',
    this.companyRuc = '',
    this.companyEmail = '',
    this.companyPhone = '',
    this.address = '',
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SignUpProviderState copyWith({
    int? step,
    String? email,
    String? username,
    String? password,
    String? confirmPassword,
    String? verificationLink,
    bool? emailVerified,
    int? accountId,
    int? signupIntentId,
    String? fullName,
    String? phone,
    String? birthDate,
    String? documentType,
    String? documentNumber,
    String? ruc,
    String? legalName,
    String? commercialName,
    String? companyRuc,
    String? companyEmail,
    String? companyPhone,
    String? address,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return SignUpProviderState(
      step: step ?? this.step,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      verificationLink: verificationLink ?? this.verificationLink,
      emailVerified: emailVerified ?? this.emailVerified,
      accountId: accountId ?? this.accountId,
      signupIntentId: signupIntentId ?? this.signupIntentId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      ruc: ruc ?? this.ruc,
      legalName: legalName ?? this.legalName,
      commercialName: commercialName ?? this.commercialName,
      companyRuc: companyRuc ?? this.companyRuc,
      companyEmail: companyEmail ?? this.companyEmail,
      companyPhone: companyPhone ?? this.companyPhone,
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        step,
        email,
        username,
        password,
        confirmPassword,
        verificationLink,
        emailVerified,
        accountId,
        signupIntentId,
        fullName,
        phone,
        birthDate,
        documentType,
        documentNumber,
        ruc,
        legalName,
        commercialName,
        companyRuc,
        companyEmail,
        companyPhone,
        address,
        isLoading,
        error,
        isSuccess,
      ];
}


