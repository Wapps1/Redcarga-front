part of 'driver_tracking_bloc.dart';

enum DriverTrackingStatus {
  initial,
  connecting,
  connected,
  permissionDenied,
  error,
}

class DriverTrackingState extends Equatable {
  final DriverTrackingStatus status;
  final DriverLocation? lastLocation;

  const DriverTrackingState({
    required this.status,
    required this.lastLocation,
  });

  const DriverTrackingState.initial()
      : status = DriverTrackingStatus.initial,
        lastLocation = null;

  DriverTrackingState copyWith({
    DriverTrackingStatus? status,
    DriverLocation? lastLocation,
  }) {
    return DriverTrackingState(
      status: status ?? this.status,
      lastLocation: lastLocation ?? this.lastLocation,
    );
  }

  @override
  List<Object?> get props => [status, lastLocation];
}