class DriverLocation {
  final int quoteId;
  final int driverId;
  final double lat;
  final double lng;
  final double? speed;
  final DateTime updatedAt;

  const DriverLocation({
    required this.quoteId,
    required this.driverId,
    required this.lat,
    required this.lng,
    this.speed,
    required this.updatedAt,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      quoteId: json['quoteId'] as int,
      driverId: json['driverId'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      updatedAt: DateTime.parse(json['timestamp'] as String? ?? json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toUpdatePayload() => {
        'lat': lat,
        'lng': lng,
        if (speed != null) 'speed': speed,
      };
}