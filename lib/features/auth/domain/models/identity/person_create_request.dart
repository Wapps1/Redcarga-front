class PersonCreateRequest {
  final int accountId;
  final String fullName;
  final String docTypeCode;
  final String docNumber;
  final String birthDate; // formato: yyyy-MM-dd
  final String phone;
  final String ruc;

  PersonCreateRequest({
    required this.accountId,
    required this.fullName,
    required this.docTypeCode,
    required this.docNumber,
    required this.birthDate,
    required this.phone,
    required this.ruc,
  });
}

