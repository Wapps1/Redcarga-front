class RequestDto {
  final int requestId;
  final String requestName;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? closedAt;
  final LocationDto origin;
  final LocationDto destination;
  final int itemsCount;
  final double totalWeightKg;
  final bool paymentOnDelivery;

  RequestDto({
    required this.requestId,
    required this.requestName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    required this.origin,
    required this.destination,
    required this.itemsCount,
    required this.totalWeightKg,
    required this.paymentOnDelivery,
  });

  factory RequestDto.fromJson(Map<String, dynamic> json) => RequestDto(
        requestId: (json['requestId'] as num).toInt(),
        requestName: json['requestName'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        closedAt: json['closedAt'] as String?,
        origin: LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
        destination: LocationDto.fromJson(json['destination'] as Map<String, dynamic>),
        itemsCount: (json['itemsCount'] as num).toInt(),
        totalWeightKg: (json['totalWeightKg'] as num).toDouble(),
        paymentOnDelivery: json['paymentOnDelivery'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'requestName': requestName,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'closedAt': closedAt,
        'origin': origin.toJson(),
        'destination': destination.toJson(),
        'itemsCount': itemsCount,
        'totalWeightKg': totalWeightKg,
        'paymentOnDelivery': paymentOnDelivery,
      };
}

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

  factory LocationDto.fromJson(Map<String, dynamic> json) => LocationDto(
        departmentCode: json['departmentCode'] as String,
        departmentName: json['departmentName'] as String,
        provinceCode: json['provinceCode'] as String,
        provinceName: json['provinceName'] as String,
        districtText: json['districtText'] as String,
      );

  Map<String, dynamic> toJson() => {
        'departmentCode': departmentCode,
        'departmentName': departmentName,
        'provinceCode': provinceCode,
        'provinceName': provinceName,
        'districtText': districtText,
      };

  String get fullAddress => '$districtText, $provinceName, $departmentName';
}

