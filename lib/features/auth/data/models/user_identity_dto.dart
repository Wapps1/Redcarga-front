class UserIdentityDto {
  final int id;
  final int accountId;
  final String fullName;
  final String birthDate;
  final int docTypeId;
  final String docNumber;
  final String phone;
  final String? ruc;

  UserIdentityDto({
    required this.id,
    required this.accountId,
    required this.fullName,
    required this.birthDate,
    required this.docTypeId,
    required this.docNumber,
    required this.phone,
    this.ruc,
  });

  factory UserIdentityDto.fromJson(Map<String, dynamic> json) => UserIdentityDto(
        id: (json['id'] as num).toInt(),
        accountId: (json['accountId'] as num).toInt(),
        fullName: json['fullName'] as String,
        birthDate: json['birthDate'] as String,
        docTypeId: (json['docTypeId'] as num).toInt(),
        docNumber: json['docNumber'] as String,
        phone: json['phone'] as String,
        ruc: json['ruc'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'fullName': fullName,
        'birthDate': birthDate,
        'docTypeId': docTypeId,
        'docNumber': docNumber,
        'phone': phone,
        'ruc': ruc,
      };
}

