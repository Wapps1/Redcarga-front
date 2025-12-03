import 'package:meta/meta.dart';

@immutable
abstract class DriverProfileEvent {
  const DriverProfileEvent();
}

class DriverProfileStarted extends DriverProfileEvent {
  const DriverProfileStarted();
}
