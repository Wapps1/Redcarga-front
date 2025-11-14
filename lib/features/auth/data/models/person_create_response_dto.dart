class PersonCreateResponseDto {
  final int personId;

  PersonCreateResponseDto({required this.personId});

  factory PersonCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      PersonCreateResponseDto(
        personId: json['personId'] as int,
      );
}


