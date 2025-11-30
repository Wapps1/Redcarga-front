import 'dart:convert';

/// DTO para crear una solicitud
class CreateRequestDto {
  final LocationDto origin;
  final LocationDto destination;
  final bool paymentOnDelivery;
  final String requestName;
  final List<ItemDto> items;

  CreateRequestDto({
    required this.origin,
    required this.destination,
    required this.paymentOnDelivery,
    required this.requestName,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'paymentOnDelivery': paymentOnDelivery,
      'request_name': requestName,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

/// DTO para ubicación (origen/destino)
class LocationDto {
  final String departmentCode;
  final String departmentName;
  final String provinceCode;
  final String provinceName;
  final String districtText;

  LocationDto({
    required this.departmentCode,
    required this.departmentName,
    required this.provinceCode,
    required this.provinceName,
    required this.districtText,
  });

  Map<String, dynamic> toJson() {
    return {
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'provinceCode': provinceCode,
      'provinceName': provinceName,
      'districtText': districtText,
    };
  }
}

/// DTO para un artículo en la solicitud
class ItemDto {
  final String itemName;
  final double heightCm;
  final double widthCm;
  final double lengthCm;
  final double weightKg;
  final double totalWeightKg;
  final int quantity;
  final bool fragile;
  final String? notes;
  final List<ImageDto> images;

  ItemDto({
    required this.itemName,
    required this.heightCm,
    required this.widthCm,
    required this.lengthCm,
    required this.weightKg,
    required this.totalWeightKg,
    required this.quantity,
    required this.fragile,
    this.notes,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'heightCm': heightCm,
      'widthCm': widthCm,
      'lengthCm': lengthCm,
      'weightKg': weightKg,
      'totalWeightKg': totalWeightKg,
      'quantity': quantity,
      'fragile': fragile,
      if (notes != null) 'notes': notes,
      'images': images.map((image) => image.toJson()).toList(),
    };
  }
}

/// DTO para una imagen de un artículo
class ImageDto {
  final String imageUrl;
  final int imagePosition;

  ImageDto({
    required this.imageUrl,
    required this.imagePosition,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'imagePosition': imagePosition,
    };
  }
}

