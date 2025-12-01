import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../costants/api_constants.dart';
import 'models/geo_catalog_item.dart';

class GeoService {
  final http.Client _client;

  GeoService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene el catálogo geográfico completo
  Future<List<GeoCatalogItem>> getCatalog() async {
    final url = Uri.parse(ApiConstants.geoCatalogEndpoint);

    print('🌍 [GeoService] Get Catalog - GET $url');

    try {
      final response = await _client.get(
        url,
        headers: {
          'accept': '*/*',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 30 segundos');
        },
      );

      print('📥 [GeoService] Response status: ${response.statusCode}');
      print('📥 [GeoService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // El endpoint devuelve un objeto con 'departments' y 'provinces' como arrays separados
        List<dynamic> allItems = [];
        
        if (decoded is Map) {
          // Extraer departments
          if (decoded.containsKey('departments') && decoded['departments'] is List) {
            final departments = decoded['departments'] as List<dynamic>;
            allItems.addAll(departments);
            print('📦 [GeoService] Departamentos encontrados: ${departments.length}');
          }
          
          // Extraer provinces
          if (decoded.containsKey('provinces') && decoded['provinces'] is List) {
            final provinces = decoded['provinces'] as List<dynamic>;
            allItems.addAll(provinces);
            print('📦 [GeoService] Provincias encontradas: ${provinces.length}');
          }
          
          // Si no tiene 'departments' ni 'provinces', intentar otras claves comunes
          if (allItems.isEmpty) {
            if (decoded.containsKey('data') && decoded['data'] is List) {
              allItems = decoded['data'] as List<dynamic>;
            } else if (decoded.containsKey('items') && decoded['items'] is List) {
              allItems = decoded['items'] as List<dynamic>;
            } else if (decoded.containsKey('catalog') && decoded['catalog'] is List) {
              allItems = decoded['catalog'] as List<dynamic>;
            }
          }
        } else if (decoded is List) {
          // Si es directamente una lista
          allItems = decoded;
        } else {
          throw Exception('Unexpected response format: ${decoded.runtimeType}');
        }
        
        return allItems.map((json) {
          if (json is Map<String, dynamic>) {
            return GeoCatalogItem.fromJson(json);
          } else {
            throw Exception('Invalid item format: ${json.runtimeType}');
          }
        }).toList();
      } else {
        throw Exception('Failed to load catalog: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [GeoService] Error: $e');
      rethrow;
    }
  }

  /// Obtiene solo los departamentos (items sin departmentCode)
  Future<List<GeoCatalogItem>> getDepartments() async {
    final catalog = await getCatalog();
    return catalog.where((item) => item.departmentCode == null).toList();
  }

  /// Obtiene las provincias de un departamento específico
  Future<List<GeoCatalogItem>> getProvincesByDepartment(String departmentCode) async {
    final catalog = await getCatalog();
    
    print('🔍 [GeoService] Buscando provincias para departamento: $departmentCode');
    print('🔍 [GeoService] Total items en catálogo: ${catalog.length}');
    
    // Filtrar provincias que pertenecen al departamento
    final provinces = catalog.where((item) {
      final matches = item.departmentCode == departmentCode;
      if (matches) {
        print('✅ [GeoService] Provincia encontrada: ${item.name} (code: ${item.code}, deptCode: ${item.departmentCode})');
      }
      return matches;
    }).toList();
    
    // Eliminar duplicados basándose en el código de la provincia
    final uniqueProvinces = <String, GeoCatalogItem>{};
    for (var province in provinces) {
      if (!uniqueProvinces.containsKey(province.code)) {
        uniqueProvinces[province.code] = province;
      }
    }
    
    final result = uniqueProvinces.values.toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    
    print('📊 [GeoService] Provincias encontradas: ${result.length}');
    for (var prov in result) {
      print('  - ${prov.name} (${prov.code})');
    }
    
    return result;
  }

  /// Obtiene los distritos de una provincia específica
  Future<List<GeoCatalogItem>> getDistrictsByProvince(String provinceCode, String departmentCode) async {
    final catalog = await getCatalog();
    return catalog.where((item) => 
      item.code.startsWith(provinceCode) && 
      item.departmentCode == departmentCode
    ).toList();
  }
}

