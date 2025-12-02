import 'request_dto.dart';

class RequestDetailDto {
  final int requestId;
  final int requesterAccountId;
  final String requesterNameSnapshot;
  final String requestName;
  final String requesterDocNumber;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? closedAt;
  final LocationDto origin;
  final LocationDto destination;
  final int itemsCount;
  final double totalWeightKg;
  final bool paymentOnDelivery;
  final List<RequestItemDto> items;

  RequestDetailDto({
    required this.requestId,
    required this.requesterAccountId,
    required this.requesterNameSnapshot,
    required this.requestName,
    required this.requesterDocNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    required this.origin,
    required this.destination,
    required this.itemsCount,
    required this.totalWeightKg,
    required this.paymentOnDelivery,
    required this.items,
  });

  factory RequestDetailDto.fromJson(Map<String, dynamic> json) => RequestDetailDto(
        requestId: (json['requestId'] as num).toInt(),
        requesterAccountId: (json['requesterAccountId'] as num).toInt(),
        requesterNameSnapshot: json['requesterNameSnapshot'] as String,
        requestName: json['requestName'] as String,
        requesterDocNumber: json['requesterDocNumber'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        closedAt: json['closedAt'] as String?,
        origin: LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
        destination: LocationDto.fromJson(json['destination'] as Map<String, dynamic>),
        itemsCount: (json['itemsCount'] as num).toInt(),
        totalWeightKg: (json['totalWeightKg'] as num).toDouble(),
        paymentOnDelivery: json['paymentOnDelivery'] as bool,
        items: (json['items'] as List<dynamic>)
            .map((item) => RequestItemDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'requesterAccountId': requesterAccountId,
        'requesterNameSnapshot': requesterNameSnapshot,
        'requestName': requestName,
        'requesterDocNumber': requesterDocNumber,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'closedAt': closedAt,
        'origin': origin.toJson(),
        'destination': destination.toJson(),
        'itemsCount': itemsCount,
        'totalWeightKg': totalWeightKg,
        'paymentOnDelivery': paymentOnDelivery,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class RequestItemDto {
  final int itemId;
  final String itemName;
  final double heightCm;
  final double widthCm;
  final double lengthCm;
  final double weightKg;
  final double totalWeightKg;
  final int quantity;
  final bool fragile;
  final String? notes;
  final int position;
  final List<RequestItemImageDto> images;

  RequestItemDto({
    required this.itemId,
    required this.itemName,
    required this.heightCm,
    required this.widthCm,
    required this.lengthCm,
    required this.weightKg,
    required this.totalWeightKg,
    required this.quantity,
    required this.fragile,
    this.notes,
    required this.position,
    required this.images,
  });

  factory RequestItemDto.fromJson(Map<String, dynamic> json) => RequestItemDto(
        itemId: (json['itemId'] as num).toInt(),
        itemName: json['itemName'] as String,
        heightCm: (json['heightCm'] as num).toDouble(),
        widthCm: (json['widthCm'] as num).toDouble(),
        lengthCm: (json['lengthCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        totalWeightKg: (json['totalWeightKg'] as num).toDouble(),
        quantity: (json['quantity'] as num).toInt(),
        fragile: json['fragile'] as bool,
        notes: json['notes'] as String?,
        position: (json['position'] as num).toInt(),
        images: (json['images'] as List<dynamic>)
            .map((img) => RequestItemImageDto.fromJson(img as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'heightCm': heightCm,
        'widthCm': widthCm,
        'lengthCm': lengthCm,
        'weightKg': weightKg,
        'totalWeightKg': totalWeightKg,
        'quantity': quantity,
        'fragile': fragile,
        'notes': notes,
        'position': position,
        'images': images.map((img) => img.toJson()).toList(),
      };
}

class RequestItemImageDto {
  final int imageId;
  final String imageUrl;
  final int imagePosition;

  RequestItemImageDto({
    required this.imageId,
    required this.imageUrl,
    required this.imagePosition,
  });

  factory RequestItemImageDto.fromJson(Map<String, dynamic> json) => RequestItemImageDto(
        imageId: (json['imageId'] as num).toInt(),
        imageUrl: json['imageUrl'] as String,
        imagePosition: (json['imagePosition'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'imageUrl': imageUrl,
        'imagePosition': imagePosition,
      };
}

