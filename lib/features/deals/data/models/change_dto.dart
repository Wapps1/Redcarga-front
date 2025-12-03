class ChangeDto {
  final int changeId;
  final int quoteId;
  final String kindCode;
  final String statusCode;
  final int createdBy;
  final String createdAt;
  final List<ChangeItemDto> items;

  ChangeDto({
    required this.changeId,
    required this.quoteId,
    required this.kindCode,
    required this.statusCode,
    required this.createdBy,
    required this.createdAt,
    required this.items,
  });

  factory ChangeDto.fromJson(Map<String, dynamic> json) => ChangeDto(
        changeId: (json['changeId'] as num).toInt(),
        quoteId: (json['quoteId'] as num).toInt(),
        kindCode: json['kindCode'] as String,
        statusCode: json['statusCode'] as String,
        createdBy: (json['createdBy'] as num).toInt(),
        createdAt: json['createdAt'] as String,
        items: (json['items'] as List<dynamic>)
            .map((item) => ChangeItemDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'changeId': changeId,
        'quoteId': quoteId,
        'kindCode': kindCode,
        'statusCode': statusCode,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class ChangeItemDto {
  final int changeItemId;
  final String fieldCode;
  final String? oldValue;
  final String? newValue;
  final int? targetQuoteItemId;
  final int? targetRequestItemId;

  ChangeItemDto({
    required this.changeItemId,
    required this.fieldCode,
    this.oldValue,
    this.newValue,
    this.targetQuoteItemId,
    this.targetRequestItemId,
  });

  factory ChangeItemDto.fromJson(Map<String, dynamic> json) => ChangeItemDto(
        changeItemId: (json['changeItemId'] as num).toInt(),
        fieldCode: json['fieldCode'] as String,
        oldValue: json['oldValue'] as String?,
        newValue: json['newValue'] as String?,
        targetQuoteItemId: json['targetQuoteItemId'] != null
            ? (json['targetQuoteItemId'] as num).toInt()
            : null,
        targetRequestItemId: json['targetRequestItemId'] != null
            ? (json['targetRequestItemId'] as num).toInt()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'changeItemId': changeItemId,
        'fieldCode': fieldCode,
        'oldValue': oldValue,
        'newValue': newValue,
        'targetQuoteItemId': targetQuoteItemId,
        'targetRequestItemId': targetRequestItemId,
      };
}

