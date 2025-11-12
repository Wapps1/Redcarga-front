import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drivers_event.dart';
import 'drivers_state.dart';
import 'package:red_carga/features/fleet/data/driver_service.dart';
import 'package:red_carga/features/fleet/domain/driver.dart';

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  final DriverService service;

  DriversBloc({required this.service}) : super(const DriversState()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<CreateDriver>(_onCreateDriver);
    on<UpdateDriver>(_onUpdateDriver);
    on<DeleteDriver>(_onDeleteDriver);
  }

  Future<void> _onLoadDrivers(
      LoadDrivers event, Emitter<DriversState> emit) async {
    emit(state.copyWith(status: DriversStatus.loading, companyId: event.companyId, message: null));
    try {
      final list = await service.listDriversByCompany(event.companyId);
      final drivers = list.map<Driver>((e) => Driver.fromJson(_asMap(e))).toList();
      emit(state.copyWith(status: DriversStatus.success, drivers: drivers));
    } catch (e) {
      emit(state.copyWith(status: DriversStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onCreateDriver(
      CreateDriver event, Emitter<DriversState> emit) async {
    emit(state.copyWith(submitting: true, message: null));
    try {
      final created = await service.createDriver(
        companyId: event.companyId,
        name: event.name,
        dni: event.dni,
        phone: event.phone,
        licenseImage: event.licenseImage,
      );
      final driver = Driver.fromJson(_asMap(created));
      // Optimista: añade y listo (o recarga)
      final next = List<Driver>.from(state.drivers)..add(driver);
      emit(state.copyWith(submitting: false, drivers: next));
      // Si prefieres consistencia total con backend:
      // add(LoadDrivers(state.companyId ?? event.companyId));
    } catch (e) {
      emit(state.copyWith(submitting: false, message: e.toString()));
    }
  }

  Future<void> _onUpdateDriver(
      UpdateDriver event, Emitter<DriversState> emit) async {
    emit(state.copyWith(submitting: true, message: null));
    try {
      final updated = await service.updateDriver(
        driverId: event.driverId,
        payload: event.payload,
      );
      final upd = Driver.fromJson(_asMap(updated));
      final next = state.drivers
          .map((d) => d.id == upd.id ? upd : d)
          .toList(growable: false);
      emit(state.copyWith(submitting: false, drivers: next));
    } catch (e) {
      emit(state.copyWith(submitting: false, message: e.toString()));
    }
  }

  Future<void> _onDeleteDriver(
      DeleteDriver event, Emitter<DriversState> emit) async {
    emit(state.copyWith(submitting: true, message: null));
    try {
      await service.deleteDriver(event.driverId);
      final next = state.drivers.where((d) => d.id != event.driverId).toList();
      emit(state.copyWith(submitting: false, drivers: next));
    } catch (e) {
      emit(state.copyWith(submitting: false, message: e.toString()));
    }
  }

  Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.cast<String, dynamic>();
    return jsonDecode(json as String) as Map<String, dynamic>;
  }
}
