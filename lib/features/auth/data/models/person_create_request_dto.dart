class PersonCreateRequestDto {
  final int accountId;
  final String fullName;
  final String docTypeCode;
  final String docNumber;
  final String birthDate;
  final String phone;
  final String ruc;

  PersonCreateRequestDto({
    required this.accountId,
    required this.fullName,
    required this.docTypeCode,
    required this.docNumber,
    required this.birthDate,
    required this.phone,
    required this.ruc,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'fullName': fullName,
        'docTypeCode': docTypeCode,
        'docNumber': docNumber,
        'birthDate': birthDate,
        'phone': phone,
        'ruc': ruc,
      };
}

