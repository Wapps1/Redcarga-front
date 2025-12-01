class AppLoginRequestDto {
  final String platform;
  final String ip;
  //final int? ttlSeconds; // opcional (default en backend: 7200 = 2h)

  AppLoginRequestDto({
    required this.platform,
    required this.ip,
    //this.ttlSeconds,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'platform': platform,
      'ip': ip,
    };
    //if (ttlSeconds != null) {
    //  map['ttlSeconds'] = ttlSeconds!;
    //}
    return map;
  }
}

