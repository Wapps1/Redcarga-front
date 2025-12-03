class AssignmentDto {
  final int assignmentId;
  final int quoteId;
  final int driverId;
  final int vehicleId;
  final int assignedBy;
  final String assignedAt;
  final int version;

  AssignmentDto({
    required this.assignmentId,
    required this.quoteId,
    required this.driverId,
    required this.vehicleId,
    required this.assignedBy,
    required this.assignedAt,
    required this.version,
  });

  factory AssignmentDto.fromJson(Map<String, dynamic> json) => AssignmentDto(
        assignmentId: (json['assignmentId'] as num).toInt(),
        quoteId: (json['quoteId'] as num).toInt(),
        driverId: (json['driverId'] as num).toInt(),
        vehicleId: (json['vehicleId'] as num).toInt(),
        assignedBy: (json['assignedBy'] as num).toInt(),
        assignedAt: json['assignedAt'] as String,
        version: (json['version'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'assignmentId': assignmentId,
        'quoteId': quoteId,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'assignedBy': assignedBy,
        'assignedAt': assignedAt,
        'version': version,
      };
}

