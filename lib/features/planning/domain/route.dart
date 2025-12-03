class PlanningRoute {
  final int id;
  final int routeTypeId;
  final String originDepartmentCode;
  final String originDepartmentName;
  final String originProvinceCode;
  final String originProvinceName;
  final String? originDistrict;
  final String destDepartmentCode;
  final String destDepartmentName;
  final String destProvinceCode;
  final String destProvinceName;
  final String? destDistrict;
  final bool active;

  PlanningRoute({
    required this.id,
    required this.routeTypeId,
    required this.originDepartmentCode,
    required this.originDepartmentName,
    required this.originProvinceCode,
    required this.originProvinceName,
    this.originDistrict,
    required this.destDepartmentCode,
    required this.destDepartmentName,
    required this.destProvinceCode,
    required this.destProvinceName,
    this.destDistrict,
    required this.active,
  });

  factory PlanningRoute.fromJson(Map<String, dynamic> json) {
    // El endpoint devuelve routeId, no id
    final routeId = json['routeId'] ?? json['id'] ?? 0;
    
    // El endpoint devuelve routeType como string, necesitamos convertirlo a int
    // "DD" = 1, "PP" = 2, o cualquier otro valor
    int routeTypeId = 1; // Por defecto DD
    if (json.containsKey('routeType')) {
      final routeType = json['routeType'] as String?;
      if (routeType != null) {
        routeTypeId = routeType.toUpperCase() == 'PP' ? 2 : 1;
      }
    } else if (json.containsKey('routeTypeId')) {
      routeTypeId = json['routeTypeId'] as int? ?? 1;
    }
    
    // Extraer nombres con valores por defecto vacíos si son null
    final originDeptName = (json['originDepartmentName'] as String?)?.trim() ?? '';
    final originProvName = (json['originProvinceName'] as String?)?.trim() ?? '';
    final destDeptName = (json['destDepartmentName'] as String?)?.trim() ?? '';
    final destProvName = (json['destProvinceName'] as String?)?.trim() ?? '';
    
    print('🔍 [PlanningRoute] Mapeando ruta:');
    print('   - routeId: $routeId');
    print('   - Origen: provincia="$originProvName", departamento="$originDeptName"');
    print('   - Destino: provincia="$destProvName", departamento="$destDeptName"');
    
    return PlanningRoute(
      id: routeId,
      routeTypeId: routeTypeId,
      originDepartmentCode: json['originDepartmentCode'] ?? '',
      originDepartmentName: originDeptName,
      originProvinceCode: json['originProvinceCode'] ?? '',
      originProvinceName: originProvName,
      originDistrict: json['originDistrict'],
      destDepartmentCode: json['destDepartmentCode'] ?? '',
      destDepartmentName: destDeptName,
      destProvinceCode: json['destProvinceCode'] ?? '',
      destProvinceName: destProvName,
      destDistrict: json['destDistrict'],
      active: json['active'] ?? true,
    );
  }

  String get originDisplay => _formatLocation(
        originDepartmentName,
        originProvinceName,
        originDistrict,
      );

  String get destDisplay => _formatLocation(
        destDepartmentName,
        destProvinceName,
        destDistrict,
      );

  String _formatLocation(String dept, String prov, String? dist) {
    final parts = <String>[];
    
    // Debug: verificar qué valores estamos recibiendo
    print('🔍 [PlanningRoute._formatLocation] dept="$dept", prov="$prov", dist="$dist"');
    
    // Orden: provincia, departamento (sin distrito según el diseño)
    // Mostrar provincia si está disponible y no está vacía
    final provTrimmed = prov.trim();
    if (provTrimmed.isNotEmpty) {
      parts.add(provTrimmed);
      print('✅ [PlanningRoute._formatLocation] Agregando provincia: "$provTrimmed"');
    } else {
      print('⚠️ [PlanningRoute._formatLocation] Provincia vacía o null');
    }
    
    // Mostrar departamento si está disponible y no está vacío
    final deptTrimmed = dept.trim();
    if (deptTrimmed.isNotEmpty) {
      parts.add(deptTrimmed);
      print('✅ [PlanningRoute._formatLocation] Agregando departamento: "$deptTrimmed"');
    } else {
      print('⚠️ [PlanningRoute._formatLocation] Departamento vacío o null');
    }
    
    final result = parts.isEmpty ? 'Ubicación no especificada' : parts.join(', ');
    print('📋 [PlanningRoute._formatLocation] Resultado: "$result"');
    
    return result;
  }
}

