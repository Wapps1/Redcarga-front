// lib/features/requests/presentation/blocs/request_inbox_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/request_inbox_service.dart';
import '../../domain/models/request_inbox_item.dart';
import 'request_inbox_event.dart';
import 'request_inbox_state.dart';

class RequestInboxBloc extends Bloc<RequestInboxEvent, RequestInboxState> {
  final RequestInboxService service;
  
  RequestInboxBloc({required this.service}) : super(const RequestInboxState()) {
    on<RequestInboxLoad>(_onLoad);
    on<RequestInboxRefresh>(_onRefresh);
  }

  Future<void> _onLoad(
    RequestInboxLoad e,
    Emitter<RequestInboxState> emit,
  ) async {
    emit(state.copyWith(status: RequestInboxStatus.loading));
    try {
      final list = await service.getRequestInbox(companyId: e.companyId);
      emit(state.copyWith(
        status: RequestInboxStatus.success,
        requests: list,
        message: null,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: RequestInboxStatus.failure,
        message: err.toString(),
      ));
    }
  }

  Future<void> _onRefresh(
    RequestInboxRefresh e,
    Emitter<RequestInboxState> emit,
  ) async {
    emit(state.copyWith(status: RequestInboxStatus.loading));
    try {
      final list = await service.getRequestInbox(companyId: e.companyId);
      emit(state.copyWith(
        status: RequestInboxStatus.success,
        requests: list,
        message: null,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: RequestInboxStatus.failure,
        message: err.toString(),
      ));
    }
  }
}


