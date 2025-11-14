import '../../domain/models/identity/person_create_request.dart';
import '../../domain/models/identity/person_create_result.dart';
import '../models/person_create_request_dto.dart';
import '../models/person_create_response_dto.dart';

extension PersonCreateRequestToDto on PersonCreateRequest {
  PersonCreateRequestDto toDto() {
    return PersonCreateRequestDto(
      accountId: accountId,
      fullName: fullName,
      docTypeCode: docTypeCode,
      docNumber: docNumber,
      birthDate: birthDate,
      phone: phone,
      ruc: ruc,
    );
  }
}

extension PersonCreateResponseDtoToDomain on PersonCreateResponseDto {
  PersonCreateResult toDomain() {
    return PersonCreateResult(personId: personId);
  }
}


