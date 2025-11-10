class CompanyRegisterRequestDto {
  final int accountId;
  final String legalName;
  final String tradeName;
  final String ruc;
  final String email;
  final String phone;
  final String address;

  CompanyRegisterRequestDto({
    required this.accountId,
    required this.legalName,
    required this.tradeName,
    required this.ruc,
    required this.email,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'legalName': legalName,
        'tradeName': tradeName,
        'ruc': ruc,
        'email': email,
        'phone': phone,
        'address': address,
      };
}

