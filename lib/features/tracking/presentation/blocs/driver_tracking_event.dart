part of 'driver_tracking_bloc.dart';

abstract class DriverTrackingEvent extends Equatable {
  const DriverTrackingEvent();
  @override
  List<Object?> get props => [];
}

class DriverTrackingStarted extends DriverTrackingEvent {
  const DriverTrackingStarted();
}

class _DriverLocationReceived extends DriverTrackingEvent {
  final DriverLocation location;
  const _DriverLocationReceived(this.location);
  @override
  List<Object?> get props => [location];
}