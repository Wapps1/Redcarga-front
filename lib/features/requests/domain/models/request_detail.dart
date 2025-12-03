class RequestDetail {
  final int requestId;
  final int requesterAccountId;
  final String requesterNameSnapshot;
  final String requestName;
  final String requesterDocNumber;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final RequestLocation origin;
  final RequestLocation destination;
  final int itemsCount;
  final double totalWeightKg;
  final bool paymentOnDelivery;
  final List<RequestDetailItem> items;

  RequestDetail({
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

  factory RequestDetail.fromJson(Map<String, dynamic> json) {
    return RequestDetail(
      requestId: json['requestId'] ?? 0,
      requesterAccountId: json['requesterAccountId'] ?? 0,
      requesterNameSnapshot: json['requesterNameSnapshot'] ?? '',
      requestName: json['requestName'] ?? '',
      requesterDocNumber: json['requesterDocNumber'] ?? '',
      status: json['status'] ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      origin: RequestLocation.fromJson(json['origin'] as Map<String, dynamic>),
      destination: RequestLocation.fromJson(json['destination'] as Map<String, dynamic>),
      itemsCount: json['itemsCount'] ?? 0,
      totalWeightKg: (json['totalWeightKg'] ?? 0).toDouble(),
      paymentOnDelivery: json['paymentOnDelivery'] ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => RequestDetailItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    return '$day/$month/$year';
  }

  String get originDisplay {
    final parts = <String>[];
    if (origin.districtText != null && origin.districtText!.isNotEmpty) {
      parts.add(origin.districtText!);
    }
    if (origin.provinceName.isNotEmpty) {
      parts.add(origin.provinceName);
    }
    if (origin.departmentName.isNotEmpty) {
      parts.add(origin.departmentName);
    }
    return parts.isEmpty ? 'Ubicación no especificada' : parts.join(', ');
  }

  String get destDisplay {
    final parts = <String>[];
    if (destination.districtText != null && destination.districtText!.isNotEmpty) {
      parts.add(destination.districtText!);
    }
    if (destination.provinceName.isNotEmpty) {
      parts.add(destination.provinceName);
    }
    if (destination.departmentName.isNotEmpty) {
      parts.add(destination.departmentName);
    }
    return parts.isEmpty ? 'Ubicación no especificada' : parts.join(', ');
  }
}

class RequestLocation {
  final String departmentCode;
  final String departmentName;
  final String provinceCode;
  final String provinceName;
  final String? districtText;

  RequestLocation({
    required this.departmentCode,
    required this.departmentName,
    required this.provinceCode,
    required this.provinceName,
    this.districtText,
  });

  factory RequestLocation.fromJson(Map<String, dynamic> json) {
    return RequestLocation(
      departmentCode: json['departmentCode'] ?? '',
      departmentName: json['departmentName'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      provinceName: json['provinceName'] ?? '',
      districtText: json['districtText'],
    );
  }
}

class RequestDetailItem {
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
  final List<RequestItemImage> images;

  RequestDetailItem({
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

  factory RequestDetailItem.fromJson(Map<String, dynamic> json) {
    return RequestDetailItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      heightCm: (json['heightCm'] ?? 0).toDouble(),
      widthCm: (json['widthCm'] ?? 0).toDouble(),
      lengthCm: (json['lengthCm'] ?? 0).toDouble(),
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      totalWeightKg: (json['totalWeightKg'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      fragile: json['fragile'] ?? false,
      notes: json['notes'],
      position: json['position'] ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => RequestItemImage.fromJson(img as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RequestItemImage {
  final int imageId;
  final String imageUrl;
  final int imagePosition;

  RequestItemImage({
    required this.imageId,
    required this.imageUrl,
    required this.imagePosition,
  });

  factory RequestItemImage.fromJson(Map<String, dynamic> json) {
    return RequestItemImage(
      imageId: json['imageId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      imagePosition: json['imagePosition'] ?? 0,
    );
  }
}



