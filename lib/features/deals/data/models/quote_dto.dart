class QuoteDto {
  final int quoteId;
  final int requestId;
  final int companyId;
  final double totalAmount;
  final String currencyCode;
  final String createdAt;

  QuoteDto({
    required this.quoteId,
    required this.requestId,
    required this.companyId,
    required this.totalAmount,
    required this.currencyCode,
    required this.createdAt,
  });

  factory QuoteDto.fromJson(Map<String, dynamic> json) => QuoteDto(
        quoteId: (json['quoteId'] as num).toInt(),
        requestId: (json['requestId'] as num).toInt(),
        companyId: (json['companyId'] as num).toInt(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        currencyCode: json['currencyCode'] as String,
        createdAt: json['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'quoteId': quoteId,
        'requestId': requestId,
        'companyId': companyId,
        'totalAmount': totalAmount,
        'currencyCode': currencyCode,
        'createdAt': createdAt,
      };
}

