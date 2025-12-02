import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:red_carga/features/auth/domain/models/iam/registration_request.dart';
import 'package:red_carga/features/auth/domain/models/identity/person_create_request.dart';
import 'package:red_carga/features/auth/domain/models/value/email.dart';
import 'package:red_carga/features/auth/domain/models/value/password.dart';
import 'package:red_carga/features/auth/domain/models/value/platform.dart' as auth_platform;
import 'package:red_carga/features/auth/domain/models/value/role_code.dart';
import 'package:red_carga/features/auth/domain/models/value/username.dart';
import 'package:red_carga/features/auth/domain/repositories/auth_remote_repository.dart';
import 'package:red_carga/features/auth/domain/repositories/firebase_auth_repository.dart';
import 'package:red_carga/features/fleet/data/driver_identity_service.dart';
import 'package:red_carga/features/fleet/data/driver_service.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_state.dart';

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  final DriverService _driverService;
  final AuthRemoteRepository _authRemoteRepository;
  final DriverIdentityService _driverIdentityService;
  final FirebaseAuthRepository _firebaseAuthRepository;

  DriversBloc({
    required DriverService driverService,
    required AuthRemoteRepository authRemoteRepository,
    required DriverIdentityService driverIdentityService,
    required FirebaseAuthRepository firebaseAuthRepository,
  })  : _driverService = driverService,
        _authRemoteRepository = authRemoteRepository,
        _driverIdentityService = driverIdentityService,
        _firebaseAuthRepository = firebaseAuthRepository,
        super(const DriversState()) {
    on<DriversRequested>(_onDriversRequested);
    on<DriverCreationFlowReset>(_onResetFlow);
    on<DriverRegisterAccountRequested>(_onRegisterDriverAccount);
    on<DriverIdentitySubmitted>(_onIdentitySubmitted);
    on<CreateDriverRequested>(_onCreateDriver);
    on<DriverFirebaseLoginRequested>(_onFirebaseLogin);
  }

  Future<void> _onDriversRequested(
    DriversRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(status: DriversStatus.loading));

    try {
      final drivers = await _driverService.getDrivers(companyId: event.companyId);
      emit(
        state.copyWith(
          status: DriversStatus.success,
          drivers: drivers,
          message: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DriversStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRegisterDriverAccount(
    DriverRegisterAccountRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(registeringAccount: true, creationMessage: null));

    try {
      final request = RegistrationRequest(
        email: Email(event.email.trim()),
        username: Username(event.username.trim()),
        password: Password(event.password),
        roleCode: RoleCode.provider,
        platform: auth_platform.Platform.web,
      );

      final result = await _authRemoteRepository.registerStart(request);

      emit(
        state.copyWith(
          registeringAccount: false,
          pendingAccountId: result.accountId,
          verificationLink: result.verificationLink,
          creationMessage: null,
          firebaseReady: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          registeringAccount: false,
          creationMessage: 'No se pudo registrar la cuenta: $e',
        ),
      );
    }
  }

  Future<void> _onFirebaseLogin(
    DriverFirebaseLoginRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(
      state.copyWith(
        firebaseSigningIn: true,
        firebaseReady: false,
        creationMessage: null,
      ),
    );

    try {
      await _firebaseAuthRepository.signInWithPassword(
        Email(event.email.trim()),
        Password(event.password),
      );

      emit(
        state.copyWith(
          firebaseSigningIn: false,
          firebaseReady: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          firebaseSigningIn: false,
          firebaseReady: false,
          creationMessage: 'No se pudo autenticar en Firebase: $e',
        ),
      );
    }
  }

  Future<void> _onIdentitySubmitted(
    DriverIdentitySubmitted event,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(verifyingIdentity: true, creationMessage: null));

    try {
      final request = PersonCreateRequest(
        accountId: event.accountId,
        fullName: event.fullName,
        docTypeCode: event.docTypeCode,
        docNumber: event.docNumber,
        birthDate: event.birthDate.toIso8601String().split('T').first,
        phone: event.phone,
        ruc: event.ruc,
      );

      await _driverIdentityService.verifyAndCreatePerson(request);

      emit(
        state.copyWith(
          verifyingIdentity: false,
          identityVerified: true,
          creationMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          verifyingIdentity: false,
          identityVerified: false,
          creationMessage: 'No se pudo verificar la identidad: $e',
        ),
      );
    }
  }

  Future<void> _onCreateDriver(
    CreateDriverRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(creating: true, creationMessage: null));

    try {
      await _driverService.registerOperator(
        companyId: event.companyId,
        accountId: event.accountId,
      );

      await _driverService.createDriver(
        companyId: event.companyId,
        accountId: event.accountId,
        licenseNumber: event.licenseNumber,
        active: event.active,
        plateImageUrl: event.plateImageUrl,
      );

      final drivers = await _driverService.getDrivers(companyId: event.companyId);

      emit(
        state.copyWith(
          creating: false,
          status: DriversStatus.success,
          drivers: drivers,
          creationMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          creating: false,
          creationMessage: 'No se pudo crear el conductor: $e',
        ),
      );
    }
  }

  FutureOr<void> _onResetFlow(
    DriverCreationFlowReset event,
    Emitter<DriversState> emit,
  ) async {
    await _firebaseAuthRepository.signOut();

    emit(
      state.copyWith(
        registeringAccount: false,
        verifyingIdentity: false,
        creating: false,
        pendingAccountId: null,
        verificationLink: null,
        identityVerified: false,
        creationMessage: null,
        firebaseSigningIn: false,
        firebaseReady: false,
      ),
    );
  }
}