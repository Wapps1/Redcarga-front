class QuoteDetailDto {
  final int quoteId;
  final int requestId;
  final int companyId;
  final int createdByAccountId;
  final String stateCode;
  final String currencyCode;
  final double totalAmount;
  final int version;
  final String createdAt;
  final String updatedAt;
  final List<QuoteItemDto> items;

  QuoteDetailDto({
    required this.quoteId,
    required this.requestId,
    required this.companyId,
    required this.createdByAccountId,
    required this.stateCode,
    required this.currencyCode,
    required this.totalAmount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory QuoteDetailDto.fromJson(Map<String, dynamic> json) => QuoteDetailDto(
        quoteId: (json['quoteId'] as num).toInt(),
        requestId: (json['requestId'] as num).toInt(),
        companyId: (json['companyId'] as num).toInt(),
        createdByAccountId: (json['createdByAccountId'] as num).toInt(),
        stateCode: json['stateCode'] as String,
        currencyCode: json['currencyCode'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        version: (json['version'] as num).toInt(),
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        items: (json['items'] as List<dynamic>)
            .map((item) => QuoteItemDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'quoteId': quoteId,
        'requestId': requestId,
        'companyId': companyId,
        'createdByAccountId': createdByAccountId,
        'stateCode': stateCode,
        'currencyCode': currencyCode,
        'totalAmount': totalAmount,
        'version': version,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class QuoteItemDto {
  final int quoteItemId;
  final int requestItemId;
  final int qty;
  final int version;

  QuoteItemDto({
    required this.quoteItemId,
    required this.requestItemId,
    required this.qty,
    required this.version,
  });

  factory QuoteItemDto.fromJson(Map<String, dynamic> json) => QuoteItemDto(
        quoteItemId: (json['quoteItemId'] as num).toInt(),
        requestItemId: (json['requestItemId'] as num).toInt(),
        qty: (json['qty'] as num).toInt(),
        version: (json['version'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'quoteItemId': quoteItemId,
        'requestItemId': requestItemId,
        'qty': qty,
        'version': version,
      };
}

