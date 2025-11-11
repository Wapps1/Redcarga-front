class CompanyRegisterResponseDto {
  final int companyId;

  CompanyRegisterResponseDto({required this.companyId});

  factory CompanyRegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      CompanyRegisterResponseDto(
        companyId: json['companyId'] as int,
      );
}

