class ChatListDto {
  final List<ChatItemDto> chats;

  ChatListDto({
    required this.chats,
  });

  factory ChatListDto.fromJson(Map<String, dynamic> json) => ChatListDto(
        chats: (json['chats'] as List<dynamic>)
            .map((item) => ChatItemDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'chats': chats.map((item) => item.toJson()).toList(),
      };
}

class ChatItemDto {
  final int quoteId;
  final int otherUserId;
  final int otherCompanyId;
  final String? otherCompanyLegalName;
  final String? otherCompanyTradeName;
  final String? otherPersonFullName;
  final int unreadCount;

  ChatItemDto({
    required this.quoteId,
    required this.otherUserId,
    required this.otherCompanyId,
    this.otherCompanyLegalName,
    this.otherCompanyTradeName,
    this.otherPersonFullName,
    required this.unreadCount,
  });

  factory ChatItemDto.fromJson(Map<String, dynamic> json) => ChatItemDto(
        quoteId: (json['quoteId'] as num).toInt(),
        otherUserId: (json['otherUserId'] as num).toInt(),
        otherCompanyId: (json['otherCompanyId'] as num).toInt(),
        otherCompanyLegalName: json['otherCompanyLegalName'] as String?,
        otherCompanyTradeName: json['otherCompanyTradeName'] as String?,
        otherPersonFullName: json['otherPersonFullName'] as String?,
        unreadCount: (json['unreadCount'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'quoteId': quoteId,
        'otherUserId': otherUserId,
        'otherCompanyId': otherCompanyId,
        'otherCompanyLegalName': otherCompanyLegalName,
        'otherCompanyTradeName': otherCompanyTradeName,
        'otherPersonFullName': otherPersonFullName,
        'unreadCount': unreadCount,
      };
}

