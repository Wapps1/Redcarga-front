// lib/features/planning/presentation/blocs/routes_event.dart
abstract class RoutesEvent {}

class RoutesRequested extends RoutesEvent {
  final int companyId;
  RoutesRequested(this.companyId);
}

class CreateRouteRequested extends RoutesEvent {
  final int companyId;
  final int routeTypeId;
  final String originDepartmentCode;
  final String originProvinceCode;
  final String destDepartmentCode;
  final String destProvinceCode;

  CreateRouteRequested({
    required this.companyId,
    required this.routeTypeId,
    required this.originDepartmentCode,
    required this.originProvinceCode,
    required this.destDepartmentCode,
    required this.destProvinceCode,
  });
}


