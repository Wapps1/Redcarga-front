// lib/features/requests/presentation/blocs/request_inbox_state.dart
import '../../domain/models/request_inbox_item.dart';

enum RequestInboxStatus { initial, loading, success, failure }

class RequestInboxState {
  final RequestInboxStatus status;
  final List<RequestInboxItem> requests;
  final String? message;

  const RequestInboxState({
    this.status = RequestInboxStatus.initial,
    this.requests = const [],
    this.message,
  });

  RequestInboxState copyWith({
    RequestInboxStatus? status,
    List<RequestInboxItem>? requests,
    String? message,
  }) =>
      RequestInboxState(
        status: status ?? this.status,
        requests: requests ?? this.requests,
        message: message,
      );
}



