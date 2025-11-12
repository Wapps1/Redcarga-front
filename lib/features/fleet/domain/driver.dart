class Driver {
  final int id;
  final String name;
  final String dni;
  final String phone;
  final String? licenseUrl;
  final int? companyId;

  const Driver({
    required this.id,
    required this.name,
    required this.dni,
    required this.phone,
    this.licenseUrl,
    this.companyId,
  });

  Driver copyWith({
    int? id,
    String? name,
    String? dni,
    String? phone,
    String? licenseUrl,
    int? companyId,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      dni: dni ?? this.dni,
      phone: phone ?? this.phone,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      companyId: companyId ?? this.companyId,
    );
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? json['driverId'],
      name: json['name'] ?? json['fullName'] ?? '',
      dni: json['dni'] ?? json['document'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      licenseUrl: json['licenseUrl'] ?? json['license_url'],
      companyId: json['companyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dni': dni,
      'phone': phone,
      if (licenseUrl != null) 'licenseUrl': licenseUrl,
      if (companyId != null) 'companyId': companyId,
    };
  }

  @override
  String toString() => 'Driver(id: $id, name: $name)';
}
