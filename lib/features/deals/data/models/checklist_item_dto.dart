class ChecklistItemDto {
  final int instanceItemId;
  final int instanceId;
  final String code;
  final String statusCode; // PENDING, DONE
  final int? completedBy;
  final String? completedAt;

  ChecklistItemDto({
    required this.instanceItemId,
    required this.instanceId,
    required this.code,
    required this.statusCode,
    this.completedBy,
    this.completedAt,
  });

  factory ChecklistItemDto.fromJson(Map<String, dynamic> json) => ChecklistItemDto(
        instanceItemId: (json['instanceItemId'] as num).toInt(),
        instanceId: (json['instanceId'] as num).toInt(),
        code: json['code'] as String,
        statusCode: json['statusCode'] as String,
        completedBy: json['completedBy'] != null
            ? (json['completedBy'] as num).toInt()
            : null,
        completedAt: json['completedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'instanceItemId': instanceItemId,
        'instanceId': instanceId,
        'code': code,
        'statusCode': statusCode,
        'completedBy': completedBy,
        'completedAt': completedAt,
      };

  bool get isCompleted => statusCode == 'DONE';
}

