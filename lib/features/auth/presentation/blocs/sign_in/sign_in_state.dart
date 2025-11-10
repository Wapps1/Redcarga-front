import 'package:equatable/equatable.dart';

class SignInState extends Equatable {
  final String email;
  final String password;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SignInState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SignInState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
    );
  }

  @override
  List<Object?> get props => [email, password, isLoading, error, isSuccess];
}

