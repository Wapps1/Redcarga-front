import '../value/platform.dart';

class AppLoginRequest {
  final Platform platform;
  final String ip;
  final int? ttlSeconds; // opcional (default en backend: 7200 = 2h)

  AppLoginRequest({
    required this.platform,
    required this.ip,
    this.ttlSeconds,
  });
}

