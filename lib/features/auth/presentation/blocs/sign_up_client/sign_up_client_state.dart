import 'package:equatable/equatable.dart';

class SignUpClientState extends Equatable {
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
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SignUpClientState({
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
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SignUpClientState copyWith({
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
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return SignUpClientState(
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
        isLoading,
        error,
        isSuccess,
      ];
}

