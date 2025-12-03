class GuideDto {
  final int guideId;
  final String type;
  final int quoteId;
  final String guideUrl;

  GuideDto({
    required this.guideId,
    required this.type,
    required this.quoteId,
    required this.guideUrl,
  });

  factory GuideDto.fromJson(Map<String, dynamic> json) => GuideDto(
        guideId: (json['guideId'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        quoteId: (json['quoteId'] as num?)?.toInt() ?? 0,
        guideUrl: json['guideUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'guideId': guideId,
        'type': type,
        'quoteId': quoteId,
        'guideUrl': guideUrl,
      };
}

