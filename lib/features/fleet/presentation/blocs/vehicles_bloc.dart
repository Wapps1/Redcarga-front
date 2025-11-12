import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'vehicles_event.dart';
import 'vehicles_state.dart';
import 'package:red_carga/features/fleet/data/vehicle_service.dart';
import 'package:red_carga/features/fleet/domain/vehicle.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  final VehicleService service;

  VehiclesBloc({required this.service}) : super(const VehiclesState()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
      LoadVehicles event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(status: VehiclesStatus.loading, companyId: event.companyId, message: null));
    try {
      final list = await service.listVehiclesByCompany(event.companyId);
      final vehicles = list.map<Vehicle>((e) => Vehicle.fromJson(_asMap(e))).toList();
      emit(state.copyWith(status: VehiclesStatus.success, vehicles: vehicles));
    } catch (e) {
      emit(state.copyWith(status: VehiclesStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(submitting: true, message: null));
    try {
      final created = await service.createVehicle(
        companyId: event.companyId,
        name: event.name,
        plate: event.plate,
      );
      final vehicle = Vehicle.fromJson(_asMap(created));
      final next = List<Vehicle>.from(state.vehicles)..add(vehicle);
      emit(state.copyWith(submitting: false, vehicles: next));
      // Para recargar desde backend:
      // add(LoadVehicles(state.companyId ?? event.companyId));
    } catch (e) {
      emit(state.copyWith(submitting: false, message: e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicle event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(submitting: true, message: null));
    try {
      final updated = await service.updateVehicle(
        vehicleId: event.vehicleId,
        payload: event.payload,
      );
      final upd = Vehicle.fromJson(_asMap(updated));
      final next = state.vehicles
          .map((v) => v.id == upd.id ? upd : v)
          .toList(growable: false);
      emit(state.copyWith(submitting: false, vehicles: next));
    } catch (e) {
      emit(state.copyWith(submitting: false, message: e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehiclesState> emit) async {
    emit(state.copyWith(submitting: true, message: null));
    try {
      await service.deleteVehicle(event.vehicleId);
      final next = state.vehicles.where((v) => v.id != event.vehicleId).toList();
      emit(state.copyWith(submitting: false, vehicles: next));
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
