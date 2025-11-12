class Vehicle {
  final int id;
  final String name;  // alias interno
  final String plate; // placa
  final int? companyId;

  const Vehicle({
    required this.id,
    required this.name,
    required this.plate,
    this.companyId,
  });

  Vehicle copyWith({
    int? id,
    String? name,
    String? plate,
    int? companyId,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      companyId: companyId ?? this.companyId,
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? json['vehicleId'],
      name: json['name'] ?? '',
      plate: json['plate'] ?? json['licensePlate'] ?? '',
      companyId: json['companyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plate': plate,
      if (companyId != null) 'companyId': companyId,
    };
  }

  @override
  String toString() => 'Vehicle(id: $id, plate: $plate)';
}
