import 'dart:convert';

class ChatDto {
  final int lastReadMessageId;
  final List<ChatMessageDto> messages;

  ChatDto({
    required this.lastReadMessageId,
    required this.messages,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) => ChatDto(
        lastReadMessageId: (json['lastReadMessageId'] as num).toInt(),
        messages: (json['messages'] as List<dynamic>)
            .map((item) => ChatMessageDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'lastReadMessageId': lastReadMessageId,
        'messages': messages.map((item) => item.toJson()).toList(),
      };
}

class ChatMessageDto {
  final int messageId;
  final int quoteId;
  final String typeCode; // USER o SYSTEM
  final String contentCode; // TEXT o IMAGE
  final String? body;
  final String? mediaUrl;
  final String? clientDedupKey;
  final int createdBy;
  final String createdAt;
  final String? systemSubtypeCode; // Solo para SYSTEM
  final String? info; // Solo para SYSTEM

  ChatMessageDto({
    required this.messageId,
    required this.quoteId,
    required this.typeCode,
    required this.contentCode,
    this.body,
    this.mediaUrl,
    this.clientDedupKey,
    required this.createdBy,
    required this.createdAt,
    this.systemSubtypeCode,
    this.info,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    // Helper para convertir valores a String? de forma segura
    String? _safeString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        // Si viene como Map, convertirlo a String JSON
        try {
          return jsonEncode(value);
        } catch (e) {
          return value.toString();
        }
      }
      return value.toString();
    }
    
    return ChatMessageDto(
      messageId: (json['messageId'] as num).toInt(),
      quoteId: (json['quoteId'] as num).toInt(),
      typeCode: json['typeCode'] as String,
      contentCode: json['contentCode'] as String,
      body: _safeString(json['body']),
      mediaUrl: _safeString(json['mediaUrl']),
      clientDedupKey: _safeString(json['clientDedupKey']),
      createdBy: (json['createdBy'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      systemSubtypeCode: _safeString(json['systemSubtypeCode']),
      info: _safeString(json['info']),
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'quoteId': quoteId,
        'typeCode': typeCode,
        'contentCode': contentCode,
        'body': body,
        'mediaUrl': mediaUrl,
        'clientDedupKey': clientDedupKey,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'systemSubtypeCode': systemSubtypeCode,
        'info': info,
      };
}

