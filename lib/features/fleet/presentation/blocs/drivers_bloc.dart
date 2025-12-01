import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:red_carga/features/fleet/data/driver_service.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_state.dart';
import 'package:red_carga/features/auth/domain/repositories/auth_remote_repository.dart';
import 'package:red_carga/features/auth/domain/repositories/identity_remote_repository.dart';
import 'package:red_carga/features/auth/domain/models/value/email.dart';
import 'package:red_carga/features/auth/domain/models/value/username.dart';
import 'package:red_carga/features/auth/domain/models/value/password.dart';
import 'package:red_carga/features/auth/domain/models/value/role_code.dart';
import 'package:red_carga/features/auth/domain/models/value/platform.dart';
import 'package:red_carga/features/auth/domain/models/iam/registration_request.dart';
import 'package:red_carga/features/auth/domain/models/identity/person_create_request.dart';
import 'package:red_carga/features/fleet/data/driver_identity_service.dart';

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  final DriverService _driverService;
  final AuthRemoteRepository _authRemoteRepository;
  final DriverIdentityService _driverIdentityService;

  DriversBloc({
    required DriverService driverService,
    required AuthRemoteRepository authRemoteRepository,
    required DriverIdentityService driverIdentityService,
  })  : _driverService = driverService,
        _authRemoteRepository = authRemoteRepository,
        _driverIdentityService = driverIdentityService,
        super(const DriversState()) {
    on<DriversRequested>(_onLoad);
    on<DriverCreationFlowReset>(_onResetFlow);
    on<DriverRegisterAccountRequested>(_onRegisterAccount);
    on<DriverIdentitySubmitted>(_onIdentitySubmit);
    on<CreateDriverRequested>(_onCreateDriver);
  }

  Future<void> _onLoad(
    DriversRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(status: DriversStatus.loading, message: null));
    try {
      final list = await _driverService.getDrivers(companyId: event.companyId);
      emit(
        state.copyWith(
          status: DriversStatus.success,
          drivers: list,
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

  void _onResetFlow(
    DriverCreationFlowReset event,
    Emitter<DriversState> emit,
  ) {
    emit(
      state.copyWith(
        registeringAccount: false,
        verifyingIdentity: false,
        creating: false,
        pendingAccountId: null,
        verificationLink: null,
        identityVerified: false,
        creationMessage: null,
      ),
    );
  }

  Future<void> _onRegisterAccount(
    DriverRegisterAccountRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(
      state.copyWith(
        registeringAccount: true,
        creationMessage: null,
        pendingAccountId: null,
        verificationLink: null,
        identityVerified: false,
      ),
    );

    try {
      final registration = RegistrationRequest(
        email: Email(event.email.trim()),
        username: Username(event.username.trim()),
        password: Password(event.password),
        roleCode: RoleCode.provider,
        platform: Platform.web,
      );

      final result = await _authRemoteRepository.registerStart(registration);

      emit(
        state.copyWith(
          registeringAccount: false,
          pendingAccountId: result.accountId,
          verificationLink: result.verificationLink,
          creationMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          registeringAccount: false,
          creationMessage: 'No se pudo crear la cuenta: $e',
        ),
      );
    }
  }

  Future<void> _onIdentitySubmit(
    DriverIdentitySubmitted event,
    Emitter<DriversState> emit,
  ) async {
    if (event.accountId <= 0) {
      emit(
        state.copyWith(
          creationMessage: 'Cuenta inválida para completar la identidad.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        verifyingIdentity: true,
        identityVerified: false,
        creationMessage: null,
      ),
    );

    try {
      final request = PersonCreateRequest(
        accountId: event.accountId,
        fullName: event.fullName.trim(),
        docTypeCode: event.docTypeCode,
        docNumber: event.docNumber.trim(),
        birthDate: _formatDate(event.birthDate),
        phone: event.phone.trim(),
        ruc: event.ruc.trim(),
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
          creationMessage: 'No se pudo registrar la identidad: $e',
        ),
      );
    }
  }

  Future<void> _onCreateDriver(
    CreateDriverRequested event,
    Emitter<DriversState> emit,
  ) async {
    emit(
      state.copyWith(
        creating: true,
        creationMessage: null,
      ),
    );

    try {
      await _driverService.createDriver(
        companyId: event.companyId,
        accountId: event.accountId,
        licenseNumber: event.licenseNumber,
        active: event.active,
        plateImageUrl: event.plateImageUrl,
      );

      final list =
          await _driverService.getDrivers(companyId: event.companyId);

      emit(
        state.copyWith(
          creating: false,
          status: DriversStatus.success,
          drivers: list,
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

  String _formatDate(DateTime date) =>
      date.toIso8601String().split('T').first;
}