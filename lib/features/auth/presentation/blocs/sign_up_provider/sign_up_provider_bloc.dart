import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/value/email.dart';
import '../../../domain/models/value/password.dart';
import '../../../domain/models/value/username.dart';
import '../../../domain/models/value/role_code.dart';
import '../../../domain/models/value/platform.dart';
import '../../../domain/models/iam/registration_request.dart';
import '../../../domain/models/identity/person_create_request.dart';
import '../../../domain/models/provider/company_register_request.dart';
import '../../../domain/models/session/app_login_request.dart';
import '../../../domain/repositories/auth_remote_repository.dart';
import '../../../domain/repositories/firebase_auth_repository.dart';
import '../../../domain/repositories/identity_remote_repository.dart';
import '../../../domain/repositories/provider_remote_repository.dart';
import 'sign_up_provider_event.dart';
import 'sign_up_provider_state.dart';

class SignUpProviderBloc
    extends Bloc<SignUpProviderEvent, SignUpProviderState> {
  final AuthRemoteRepository _authRemoteRepository;
  final FirebaseAuthRepository _firebaseAuthRepository;
  final IdentityRemoteRepository _identityRemoteRepository;
  final ProviderRemoteRepository _providerRemoteRepository;

  SignUpProviderBloc({
    required AuthRemoteRepository authRemoteRepository,
    required FirebaseAuthRepository firebaseAuthRepository,
    required IdentityRemoteRepository identityRemoteRepository,
    required ProviderRemoteRepository providerRemoteRepository,
  })  : _authRemoteRepository = authRemoteRepository,
        _firebaseAuthRepository = firebaseAuthRepository,
        _identityRemoteRepository = identityRemoteRepository,
        _providerRemoteRepository = providerRemoteRepository,
        super(const SignUpProviderState()) {
    // Credenciales
    on<SignUpProviderEmailChanged>(_onEmailChanged);
    on<SignUpProviderUsernameChanged>(_onUsernameChanged);
    on<SignUpProviderPasswordChanged>(_onPasswordChanged);
    on<SignUpProviderConfirmPasswordChanged>(_onConfirmPasswordChanged);
    // Datos personales
    on<SignUpProviderFullNameChanged>(_onFullNameChanged);
    on<SignUpProviderPhoneChanged>(_onPhoneChanged);
    on<SignUpProviderBirthDateChanged>(_onBirthDateChanged);
    on<SignUpProviderDocumentTypeChanged>(_onDocumentTypeChanged);
    on<SignUpProviderDocumentNumberChanged>(_onDocumentNumberChanged);
    on<SignUpProviderRucChanged>(_onRucChanged);
    // Datos de empresa
    on<SignUpProviderLegalNameChanged>(_onLegalNameChanged);
    on<SignUpProviderCommercialNameChanged>(_onCommercialNameChanged);
    on<SignUpProviderCompanyRucChanged>(_onCompanyRucChanged);
    on<SignUpProviderCompanyEmailChanged>(_onCompanyEmailChanged);
    on<SignUpProviderCompanyPhoneChanged>(_onCompanyPhoneChanged);
    on<SignUpProviderAddressChanged>(_onAddressChanged);
    // Acciones
    on<SignUpProviderRegisterStart>(_onRegisterStart);
    on<SignUpProviderEmailVerified>(_onEmailVerified);
    on<SignUpProviderVerifyPerson>(_onVerifyPerson);
    on<SignUpProviderRegisterCompanyAndLogin>(_onRegisterCompanyAndLogin);
    on<SignUpProviderBack>(_onBack);
  }

  void _onEmailChanged(
    SignUpProviderEmailChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(email: event.email, error: null));
  }

  void _onUsernameChanged(
    SignUpProviderUsernameChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(username: event.username, error: null));
  }

  void _onPasswordChanged(
    SignUpProviderPasswordChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(password: event.password, error: null));
  }

  void _onConfirmPasswordChanged(
    SignUpProviderConfirmPasswordChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, error: null));
  }

  void _onFullNameChanged(
    SignUpProviderFullNameChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(fullName: event.fullName, error: null));
  }

  void _onPhoneChanged(
    SignUpProviderPhoneChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(phone: event.phone, error: null));
  }

  void _onBirthDateChanged(
    SignUpProviderBirthDateChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(birthDate: event.birthDate, error: null));
  }

  void _onDocumentTypeChanged(
    SignUpProviderDocumentTypeChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(documentType: event.documentType, error: null));
  }

  void _onDocumentNumberChanged(
    SignUpProviderDocumentNumberChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(documentNumber: event.documentNumber, error: null));
  }

  void _onRucChanged(
    SignUpProviderRucChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(ruc: event.ruc, error: null));
  }

  void _onLegalNameChanged(
    SignUpProviderLegalNameChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(legalName: event.legalName, error: null));
  }

  void _onCommercialNameChanged(
    SignUpProviderCommercialNameChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(commercialName: event.commercialName, error: null));
  }

  void _onCompanyRucChanged(
    SignUpProviderCompanyRucChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(companyRuc: event.companyRuc, error: null));
  }

  void _onCompanyEmailChanged(
    SignUpProviderCompanyEmailChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(companyEmail: event.companyEmail, error: null));
  }

  void _onCompanyPhoneChanged(
    SignUpProviderCompanyPhoneChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(companyPhone: event.companyPhone, error: null));
  }

  void _onAddressChanged(
    SignUpProviderAddressChanged event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(address: event.address, error: null));
  }

  Future<void> _onRegisterStart(
    SignUpProviderRegisterStart event,
    Emitter<SignUpProviderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _authRemoteRepository.registerStart(
        RegistrationRequest(
          email: Email(state.email),
          username: Username(state.username),
          password: Password(state.password),
          roleCode: RoleCode.provider,
          platform: Platform.android,
        ),
      );

      emit(state.copyWith(
        step: 2,
        verificationLink: result.verificationLink,
        accountId: result.accountId,
        signupIntentId: result.signupIntentId,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onEmailVerified(
    SignUpProviderEmailVerified event,
    Emitter<SignUpProviderState> emit,
  ) {
    emit(state.copyWith(emailVerified: true, step: 3));
  }

  Future<void> _onVerifyPerson(
    SignUpProviderVerifyPerson event,
    Emitter<SignUpProviderState> emit,
  ) async {
    if (state.accountId == null) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Firebase sign in
      await _firebaseAuthRepository.signInWithPassword(
        Email(state.email),
        Password(state.password),
      );

      // Normalizar fecha
      String normalizedBirthDate = state.birthDate;
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(state.birthDate)) {
        final parts = state.birthDate.split('/');
        normalizedBirthDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      }

      // Crear persona
      await _identityRemoteRepository.verifyAndCreatePerson(
        PersonCreateRequest(
          accountId: state.accountId!,
          fullName: state.fullName,
          docTypeCode: state.documentType,
          docNumber: state.documentNumber,
          birthDate: normalizedBirthDate,
          phone: state.phone,
          ruc: state.ruc,
        ),
      );

      emit(state.copyWith(step: 4, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterCompanyAndLogin(
    SignUpProviderRegisterCompanyAndLogin event,
    Emitter<SignUpProviderState> emit,
  ) async {
    if (state.accountId == null) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Registrar empresa
      await _providerRemoteRepository.registerCompany(
        CompanyRegisterRequest(
          accountId: state.accountId!,
          legalName: state.legalName,
          tradeName: state.commercialName,
          ruc: state.companyRuc,
          email: Email(state.companyEmail),
          phone: state.companyPhone,
          address: state.address,
        ),
      );

      // App login
      await _authRemoteRepository.login(
        AppLoginRequest(platform: Platform.android, ip: '0.0.0.0'),
      );

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onBack(
    SignUpProviderBack event,
    Emitter<SignUpProviderState> emit,
  ) {
    if (state.step > 1) {
      emit(state.copyWith(step: state.step - 1));
    }
  }
}

