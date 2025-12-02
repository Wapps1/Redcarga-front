// lib/features/requests/presentation/blocs/request_inbox_event.dart
abstract class RequestInboxEvent {}

class RequestInboxLoad extends RequestInboxEvent {
  final int companyId;
  RequestInboxLoad(this.companyId);
}

class RequestInboxRefresh extends RequestInboxEvent {
  final int companyId;
  RequestInboxRefresh(this.companyId);
}

