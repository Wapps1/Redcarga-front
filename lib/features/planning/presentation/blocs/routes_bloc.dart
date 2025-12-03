import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:red_carga/features/planning/data/route_service.dart';
import 'package:red_carga/features/planning/domain/route.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final RouteService service;
  RoutesBloc({required this.service}) : super(const RoutesState()) {
    on<RoutesRequested>(_onLoad);
    on<CreateRouteRequested>(_onCreate);
  }

  Future<void> _onLoad(
    RoutesRequested e,
    Emitter<RoutesState> emit,
  ) async {
    emit(state.copyWith(status: RoutesStatus.loading));
    try {
      final list = await service.getRoutes(companyId: e.companyId);
      emit(state.copyWith(status: RoutesStatus.success, routes: list, message: null));
    } catch (err) {
      emit(state.copyWith(status: RoutesStatus.failure, message: err.toString()));
    }
  }

  Future<void> _onCreate(
    CreateRouteRequested e,
    Emitter<RoutesState> emit,
  ) async {
    emit(state.copyWith(creating: true, message: null));
    try {
      await service.createRoute(
        companyId: e.companyId,
        routeTypeId: e.routeTypeId,
        originDepartmentCode: e.originDepartmentCode,
        originProvinceCode: e.originProvinceCode,
        destDepartmentCode: e.destDepartmentCode,
        destProvinceCode: e.destProvinceCode,
      );
      // recargar lista
      final list = await service.getRoutes(companyId: e.companyId);
      emit(state.copyWith(creating: false, routes: list, status: RoutesStatus.success));
    } catch (err) {
      emit(state.copyWith(creating: false, message: err.toString()));
    }
  }
}


