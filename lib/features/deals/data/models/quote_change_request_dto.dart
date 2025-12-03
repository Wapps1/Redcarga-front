class QuoteChangeRequestDto {
  final List<QuoteChangeItemDto> items;

  QuoteChangeRequestDto({
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class QuoteChangeItemDto {
  final String fieldCode; // PRICE_TOTAL, ITEM_ADD, ITEM_REMOVE, QTY
  final int? targetQuoteItemId; // Para ITEM_REMOVE y QTY
  final int? targetRequestItemId; // Solo para ITEM_ADD
  final String? oldValue; // Para PRICE_TOTAL: valor anterior
  final String? newValue; // Para PRICE_TOTAL: nuevo valor, para ITEM_ADD: cantidad, para QTY: nueva cantidad

  QuoteChangeItemDto({
    required this.fieldCode,
    this.targetQuoteItemId,
    this.targetRequestItemId,
    this.oldValue,
    this.newValue,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'fieldCode': fieldCode,
    };
    
    if (targetQuoteItemId != null) {
      json['targetQuoteItemId'] = targetQuoteItemId;
    }
    
    if (targetRequestItemId != null) {
      json['targetRequestItemId'] = targetRequestItemId;
    }
    
    if (oldValue != null) {
      json['oldValue'] = oldValue;
    }
    
    if (newValue != null) {
      json['newValue'] = newValue;
    }
    
    return json;
  }
}

