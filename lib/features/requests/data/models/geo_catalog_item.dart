/// Modelo para un item del catálogo geográfico
class GeoCatalogItem {
  final String code;
  final String name;
  final String? departmentCode;
  final String? departmentName;

  GeoCatalogItem({
    required this.code,
    required this.name,
    this.departmentCode,
    this.departmentName,
  });

  factory GeoCatalogItem.fromJson(Map<String, dynamic> json) {
    return GeoCatalogItem(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      departmentCode: json['departmentCode'] as String?,
      departmentName: json['departmentName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      if (departmentCode != null) 'departmentCode': departmentCode,
      if (departmentName != null) 'departmentName': departmentName,
    };
  }
}

