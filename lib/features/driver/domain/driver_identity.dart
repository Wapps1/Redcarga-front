class DriverIdentity {
  final int id;
  final int accountId;
  final String fullName;
  final String docNumber;
  final String phone;
  final String? birthDate;
  final String? ruc;

  DriverIdentity({
    required this.id,
    required this.accountId,
    required this.fullName,
    required this.docNumber,
    required this.phone,
    this.birthDate,
    this.ruc,
  });

  factory DriverIdentity.fromJson(Map<String, dynamic> json) {
    return DriverIdentity(
      id: json['id'] as int? ?? 0,
      accountId: json['accountId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      docNumber: json['docNumber'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      birthDate: json['birthDate'] as String?,
      ruc: json['ruc'] as String?,
    );
  }
}