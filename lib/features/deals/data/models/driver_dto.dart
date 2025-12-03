class DriverDto {
  final int driverId;
  final int companyId;
  final String fullName;
  final String docNumber;
  final String phone;
  final String licenseNumber;
  final bool active;
  final String createdAt;
  final String updatedAt;

  DriverDto({
    required this.driverId,
    required this.companyId,
    required this.fullName,
    required this.docNumber,
    required this.phone,
    required this.licenseNumber,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverDto.fromJson(Map<String, dynamic> json) => DriverDto(
        driverId: (json['driverId'] as num).toInt(),
        companyId: (json['companyId'] as num).toInt(),
        fullName: json['fullName'] as String,
        docNumber: json['docNumber'] as String,
        phone: json['phone'] as String,
        licenseNumber: json['licenseNumber'] as String,
        active: json['active'] as bool,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'companyId': companyId,
        'fullName': fullName,
        'docNumber': docNumber,
        'phone': phone,
        'licenseNumber': licenseNumber,
        'active': active,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

