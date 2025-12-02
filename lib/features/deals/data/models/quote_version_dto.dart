class QuoteVersionDto {
  final int quoteId;
  final int version;

  QuoteVersionDto({
    required this.quoteId,
    required this.version,
  });

  factory QuoteVersionDto.fromJson(Map<String, dynamic> json) => QuoteVersionDto(
        quoteId: (json['quoteId'] as num).toInt(),
        version: (json['version'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'quoteId': quoteId,
        'version': version,
      };
}

