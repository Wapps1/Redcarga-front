import 'package:red_carga/features/planning/domain/route.dart';

enum RoutesStatus { initial, loading, success, failure }

class RoutesState {
  final RoutesStatus status;
  final List<PlanningRoute> routes;
  final String? message;
  final bool creating;

  const RoutesState({
    this.status = RoutesStatus.initial,
    this.routes = const [],
    this.message,
    this.creating = false,
  });

  RoutesState copyWith({
    RoutesStatus? status,
    List<PlanningRoute>? routes,
    String? message,
    bool? creating,
  }) =>
      RoutesState(
        status: status ?? this.status,
        routes: routes ?? this.routes,
        message: message,
        creating: creating ?? this.creating,
      );
}

