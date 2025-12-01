import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:red_carga/features/fleet/data/driver_service.dart';
import 'package:red_carga/features/fleet/domain/driver.dart';
import 'drivers_event.dart';
import 'drivers_state.dart';

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  final DriverService service;
  DriversBloc({required this.service}) : super(const DriversState()) {
    on<DriversRequested>(_onLoad);
    on<CreateDriverRequested>(_onCreate);
  }

  Future<void> _onLoad(
    DriversRequested e,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(status: DriversStatus.loading));
    try {
      final list = await service.getDrivers(companyId: e.companyId);
      emit(state.copyWith(status: DriversStatus.success, drivers: list, message: null));
    } catch (err) {
      emit(state.copyWith(status: DriversStatus.failure, message: err.toString()));
    }
  }

  Future<void> _onCreate(
    CreateDriverRequested e,
    Emitter<DriversState> emit,
  ) async {
    emit(state.copyWith(creating: true, message: null));
    try {
      await service.createDriver(
        companyId: e.companyId,
        firstName: e.firstName,
        lastName: e.lastName,
        email: e.email,
        phone: e.phone,
        licenseNumber: e.licenseNumber,
      );
      // recargar lista
      final list = await service.getDrivers(companyId: e.companyId);
      emit(state.copyWith(creating: false, drivers: list, status: DriversStatus.success));
    } catch (err) {
      emit(state.copyWith(creating: false, message: err.toString()));
    }
  }
}
