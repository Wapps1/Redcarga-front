class Driver {
  final int driverId;
  final int companyId;
  final String fullName;
  final String docNumber;
  final String phone;
  final String licenseNumber;
  final bool active;

  Driver({
    required this.driverId,
    required this.companyId,
    required this.fullName,
    required this.docNumber,
    required this.phone,
    required this.licenseNumber,
    required this.active,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        driverId: json['driverId'] ?? json['id'] ?? 0,
        companyId: json['companyId'] ?? 0,
        fullName: json['fullName'] ?? '',
        docNumber: json['docNumber'] ?? '',
        phone: json['phone'] ?? '',
        licenseNumber: json['licenseNumber'] ?? '',
        active: json['active'] ?? true,
      );
      
  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  String get lastName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }
}