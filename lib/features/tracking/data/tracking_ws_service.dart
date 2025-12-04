import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:stomp_dart_client/src/stomp_frame.dart';
import 'package:stomp_dart_client/src/stomp_config.dart';
import '../../auth/domain/models/session/app_session.dart';
import '../domain/driver_location.dart';

typedef LocationCallback = void Function(DriverLocation location);

class TrackingWsService {
  final String wsUrl;
  final AppSession session;
  StompClient? _client;

  TrackingWsService({
    required this.wsUrl,
    required this.session,
  });

  void connect({
    required int quoteId,
    required LocationCallback onUpdate,
    void Function()? onConnected,
    void Function(Object error)? onError,
  }) {
    _client = StompClient(
      config: StompConfig.sockJS(
        url: '$wsUrl?access_token=${session.accessToken}',
        onConnect: (frame) {
          _subscribeToQuote(quoteId, onUpdate);
          onConnected?.call();
        },
        onStompError: (frame) => onError?.call(frame.body ?? 'STOMP error'),
        onWebSocketError: (dynamic error) => onError?.call(error),
        onWebSocketDone: () => onError?.call('Socket closed'),
        connectionTimeout: const Duration(seconds: 5),
        heartbeatOutgoing: const Duration(seconds: 10),
        heartbeatIncoming: const Duration(seconds: 10),
        webSocketConnectHeaders: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      ),
    )..activate();
  }

  void _subscribeToQuote(int quoteId, LocationCallback onUpdate) {
    final dest = '/topic/quotes.$quoteId.tracking';
    _client?.subscribe(
      destination: dest,
      callback: (StompFrame frame) {
        final data = jsonDecode(frame.body!) as Map<String, dynamic>;
        onUpdate(DriverLocation.fromJson(data));
      },
    );
  }

  void sendLocation({
    required int quoteId,
    required DriverLocation payload,
  }) {
    _client?.send(
      destination: '/app/quotes.$quoteId.tracking.update',
      body: jsonEncode(payload.toUpdatePayload()),
    );
  }

  void disconnect() => _client?.deactivate();
}