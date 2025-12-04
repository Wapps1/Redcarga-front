import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/domain/models/session/app_session.dart';
import '../../data/tracking_ws_service.dart';
import '../../domain/driver_location.dart';

part 'driver_tracking_event.dart';
part 'driver_tracking_state.dart';

class DriverTrackingBloc extends Bloc<DriverTrackingEvent, DriverTrackingState> {
  final TrackingWsService wsService;
  final int quoteId;
  Stream<Position>? _positionStream;

  DriverTrackingBloc({
    required this.wsService,
    required this.quoteId,
  }) : super(const DriverTrackingState.initial()) {
    on<DriverTrackingStarted>(_onStarted);
    on<_DriverLocationReceived>(_onRemoteUpdate);
  }

  Future<void> _onStarted(
    DriverTrackingStarted event,
    Emitter<DriverTrackingState> emit,
  ) async {
    emit(state.copyWith(status: DriverTrackingStatus.connecting));
    wsService.connect(
      quoteId: quoteId,
      onUpdate: (location) => add(_DriverLocationReceived(location)),
      onError: (error) => emit(state.copyWith(status: DriverTrackingStatus.error)),
      onConnected: () => emit(state.copyWith(status: DriverTrackingStatus.connected)),
    );

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(status: DriverTrackingStatus.permissionDenied));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      emit(state.copyWith(status: DriverTrackingStatus.permissionDenied));
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    );
    _positionStream!.listen((pos) {
      final driverLocation = DriverLocation(
        quoteId: quoteId,
        driverId: wsService.session.accountId,
        lat: pos.latitude,
        lng: pos.longitude,
        speed: pos.speed * 3.6,
        updatedAt: DateTime.now(),
      );
      wsService.sendLocation(quoteId: quoteId, payload: driverLocation);
      add(_DriverLocationReceived(driverLocation));
    });
  }

  void _onRemoteUpdate(
    _DriverLocationReceived event,
    Emitter<DriverTrackingState> emit,
  ) {
    emit(
      state.copyWith(
        status: DriverTrackingStatus.connected,
        lastLocation: event.location,
      ),
    );
  }

  @override
  Future<void> close() {
    wsService.disconnect();
    return super.close();
  }
}