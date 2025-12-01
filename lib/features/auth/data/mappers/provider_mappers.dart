import '../../domain/models/provider/company_register_request.dart';
import '../../domain/models/provider/company_register_result.dart';
import '../models/company_register_request_dto.dart';
import '../models/company_register_response_dto.dart';

extension CompanyRegisterRequestToDto on CompanyRegisterRequest {
  CompanyRegisterRequestDto toDto() {
    return CompanyRegisterRequestDto(
      accountId: accountId,
      legalName: legalName,
      tradeName: tradeName,
      ruc: ruc,
      email: email.value,
      phone: phone,
      address: address,
    );
  }
}

extension CompanyRegisterResponseDtoToDomain on CompanyRegisterResponseDto {
  CompanyRegisterResult toDomain() {
    return CompanyRegisterResult(companyId: companyId);
  }
}


