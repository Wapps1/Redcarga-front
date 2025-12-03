class RequestInboxItem {
  final int requestId;
  final int companyId;
  final int? matchedRouteId;
  final int routeTypeId;
  final String status; // OPEN, ACCEPTED, etc.
  final DateTime createdAt;
  final String requesterName;
  final String originDepartmentName;
  final String? originProvinceName;
  final String destDepartmentName;
  final String? destProvinceName;
  final int totalQuantity;

  RequestInboxItem({
    required this.requestId,
    required this.companyId,
    this.matchedRouteId,
    required this.routeTypeId,
    required this.status,
    required this.createdAt,
    required this.requesterName,
    required this.originDepartmentName,
    this.originProvinceName,
    required this.destDepartmentName,
    this.destProvinceName,
    required this.totalQuantity,
  });

  factory RequestInboxItem.fromJson(Map<String, dynamic> json) {
    return RequestInboxItem(
      requestId: json['requestId'] ?? 0,
      companyId: json['companyId'] ?? 0,
      matchedRouteId: json['matchedRouteId'],
      routeTypeId: json['routeTypeId'] ?? 1,
      status: json['status'] ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      requesterName: json['requesterName'] ?? '',
      originDepartmentName: json['originDepartmentName'] ?? '',
      originProvinceName: json['originProvinceName'],
      destDepartmentName: json['destDepartmentName'] ?? '',
      destProvinceName: json['destProvinceName'],
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }

  String get originDisplay {
    final parts = <String>[];
    if (originProvinceName != null && originProvinceName!.isNotEmpty) {
      parts.add(originProvinceName!.trim());
    }
    if (originDepartmentName.isNotEmpty) {
      parts.add(originDepartmentName.trim());
    }
    return parts.isEmpty ? 'Ubicación no especificada' : parts.join(', ');
  }

  String get destDisplay {
    final parts = <String>[];
    if (destProvinceName != null && destProvinceName!.isNotEmpty) {
      parts.add(destProvinceName!.trim());
    }
    if (destDepartmentName.isNotEmpty) {
      parts.add(destDepartmentName.trim());
    }
    return parts.isEmpty ? 'Ubicación no especificada' : parts.join(', ');
  }

  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    return '$day/$month/$year';
  }

  bool get isAccepted => status.toUpperCase() == 'ACCEPTED';
}


