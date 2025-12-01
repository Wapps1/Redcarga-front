import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:red_carga/features/fleet/data/vehicle_service.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_state.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  final VehicleService _vehicleService;

  VehiclesBloc({required VehicleService vehicleService})
      : _vehicleService = vehicleService,
        super(const VehiclesState()) {
    on<VehiclesRequested>(_onRequested);
    on<VehicleCreatedRequested>(_onCreated);
  }

  Future<void> _onRequested(
    VehiclesRequested event,
    Emitter<VehiclesState> emit,
  ) async {
    emit(state.copyWith(status: VehiclesStatus.loading, message: null));
    try {
      final items =
          await _vehicleService.listByCompany(companyId: event.companyId);
      emit(
        state.copyWith(
          status: VehiclesStatus.success,
          vehicles: items,
          message: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VehiclesStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreated(
    VehicleCreatedRequested event,
    Emitter<VehiclesState> emit,
  ) async {
    emit(state.copyWith(creating: true, message: null));
    try {
      await _vehicleService.create(
        companyId: event.companyId,
        name: event.name,
        plate: event.plate,
      );
      final items =
          await _vehicleService.listByCompany(companyId: event.companyId);
      emit(
        state.copyWith(
          creating: false,
          status: VehiclesStatus.success,
          vehicles: items,
        ),
      );
    } catch (e) {
      emit(state.copyWith(creating: false, message: e.toString()));
    }
  }
}