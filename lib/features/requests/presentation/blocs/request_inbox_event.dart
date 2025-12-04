// lib/features/requests/presentation/blocs/request_inbox_event.dart
abstract class RequestInboxEvent {}

class RequestInboxLoad extends RequestInboxEvent {
  final int companyId;
  final String? status;
  RequestInboxLoad(this.companyId, {this.status});
}

class RequestInboxRefresh extends RequestInboxEvent {
  final int companyId;
  final String? status;
  RequestInboxRefresh(this.companyId, {this.status});
}






