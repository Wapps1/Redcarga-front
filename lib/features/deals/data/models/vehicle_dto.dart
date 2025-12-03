class VehicleDto {
  final int vehicleId;
  final int companyId;
  final String name;
  final String plate;
  final bool active;
  final int createdAt;
  final int updatedAt;

  VehicleDto({
    required this.vehicleId,
    required this.companyId,
    required this.name,
    required this.plate,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) => VehicleDto(
        vehicleId: (json['vehicleId'] as num).toInt(),
        companyId: (json['companyId'] as num).toInt(),
        name: json['name'] as String,
        plate: json['plate'] as String,
        active: json['active'] as bool,
        createdAt: (json['createdAt'] as num).toInt(),
        updatedAt: (json['updatedAt'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'companyId': companyId,
        'name': name,
        'plate': plate,
        'active': active,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

