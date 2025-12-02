class CompanyDto {
  final int companyId;
  final String legalName;
  final String tradeName;
  final String ruc;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String docsStatus;
  final int createdByAccountId;
  final int membersCount;

  CompanyDto({
    required this.companyId,
    required this.legalName,
    required this.tradeName,
    required this.ruc,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.docsStatus,
    required this.createdByAccountId,
    required this.membersCount,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) => CompanyDto(
        companyId: (json['companyId'] as num).toInt(),
        legalName: json['legalName'] as String,
        tradeName: json['tradeName'] as String,
        ruc: json['ruc'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        status: json['status'] as String,
        docsStatus: json['docsStatus'] as String,
        createdByAccountId: (json['createdByAccountId'] as num).toInt(),
        membersCount: (json['membersCount'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'companyId': companyId,
        'legalName': legalName,
        'tradeName': tradeName,
        'ruc': ruc,
        'email': email,
        'phone': phone,
        'address': address,
        'status': status,
        'docsStatus': docsStatus,
        'createdByAccountId': createdByAccountId,
        'membersCount': membersCount,
      };
}

