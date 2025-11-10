import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/value/email.dart';
import '../../../domain/models/value/password.dart';
import '../../../domain/models/value/username.dart';
import '../../../domain/models/value/role_code.dart';
import '../../../domain/models/value/platform.dart';
import '../../../domain/models/iam/registration_request.dart';
import '../../../domain/models/identity/person_create_request.dart';
import '../../../domain/models/session/app_login_request.dart';
import '../../../domain/repositories/auth_remote_repository.dart';
import '../../../domain/repositories/firebase_auth_repository.dart';
import '../../../domain/repositories/identity_remote_repository.dart';
import 'sign_up_client_event.dart';
import 'sign_up_client_state.dart';
import 'package:intl/intl.dart';

class SignUpClientBloc extends Bloc<SignUpClientEvent, SignUpClientState> {
  final AuthRemoteRepository _authRemoteRepository;
  final FirebaseAuthRepository _firebaseAuthRepository;
  final IdentityRemoteRepository _identityRemoteRepository;

  SignUpClientBloc({
    required AuthRemoteRepository authRemoteRepository,
    required FirebaseAuthRepository firebaseAuthRepository,
    required IdentityRemoteRepository identityRemoteRepository,
  })  : _authRemoteRepository = authRemoteRepository,
        _firebaseAuthRepository = firebaseAuthRepository,
        _identityRemoteRepository = identityRemoteRepository,
        super(const SignUpClientState()) {
    on<SignUpClientEmailChanged>(_onEmailChanged);
    on<SignUpClientUsernameChanged>(_onUsernameChanged);
    on<SignUpClientPasswordChanged>(_onPasswordChanged);
    on<SignUpClientConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpClientFullNameChanged>(_onFullNameChanged);
    on<SignUpClientPhoneChanged>(_onPhoneChanged);
    on<SignUpClientBirthDateChanged>(_onBirthDateChanged);
    on<SignUpClientDocumentTypeChanged>(_onDocumentTypeChanged);
    on<SignUpClientDocumentNumberChanged>(_onDocumentNumberChanged);
    on<SignUpClientRucChanged>(_onRucChanged);
    on<SignUpClientRegisterStart>(_onRegisterStart);
    on<SignUpClientEmailVerified>(_onEmailVerified);
    on<SignUpClientCreatePersonAndLogin>(_onCreatePersonAndLogin);
    on<SignUpClientBack>(_onBack);
  }

  void _onEmailChanged(
    SignUpClientEmailChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(email: event.email, error: null));
  }

  void _onUsernameChanged(
    SignUpClientUsernameChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(username: event.username, error: null));
  }

  void _onPasswordChanged(
    SignUpClientPasswordChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(password: event.password, error: null));
  }

  void _onConfirmPasswordChanged(
    SignUpClientConfirmPasswordChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, error: null));
  }

  void _onFullNameChanged(
    SignUpClientFullNameChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(fullName: event.fullName, error: null));
  }

  void _onPhoneChanged(
    SignUpClientPhoneChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(phone: event.phone, error: null));
  }

  void _onBirthDateChanged(
    SignUpClientBirthDateChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(birthDate: event.birthDate, error: null));
  }

  void _onDocumentTypeChanged(
    SignUpClientDocumentTypeChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(documentType: event.documentType, error: null));
  }

  void _onDocumentNumberChanged(
    SignUpClientDocumentNumberChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(documentNumber: event.documentNumber, error: null));
  }

  void _onRucChanged(
    SignUpClientRucChanged event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(ruc: event.ruc, error: null));
  }

  Future<void> _onRegisterStart(
    SignUpClientRegisterStart event,
    Emitter<SignUpClientState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _authRemoteRepository.registerStart(
        RegistrationRequest(
          email: Email(state.email),
          username: Username(state.username),
          password: Password(state.password),
          roleCode: RoleCode.client,
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
    SignUpClientEmailVerified event,
    Emitter<SignUpClientState> emit,
  ) {
    emit(state.copyWith(emailVerified: true, step: 3));
  }

  Future<void> _onCreatePersonAndLogin(
    SignUpClientCreatePersonAndLogin event,
    Emitter<SignUpClientState> emit,
  ) async {
    if (state.accountId == null) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Paso 1: Firebase sign in
      final firebaseSession = await _firebaseAuthRepository.signInWithPassword(
        Email(state.email),
        Password(state.password),
      );

      // Paso 2: Normalizar fecha de dd/MM/yyyy a yyyy-MM-dd
      String normalizedBirthDate = state.birthDate;
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(state.birthDate)) {
        final parts = state.birthDate.split('/');
        normalizedBirthDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      }

      // Paso 3: Crear persona
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

      // Paso 4: App login
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
    SignUpClientBack event,
    Emitter<SignUpClientState> emit,
  ) {
    if (state.step > 1) {
      emit(state.copyWith(step: state.step - 1));
    }
  }
}

