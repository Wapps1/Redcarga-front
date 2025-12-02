// lib/features/planning/data/route_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/core/session/session_store.dart';
import '../domain/route.dart';

class RouteService {
  final SessionStore _sessionStore;
  RouteService(this._sessionStore);

  Future<List<PlanningRoute>> getRoutes({required int companyId}) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    // GET usa /planning/providers/
    final uri = Uri.parse(ApiConstants.providerRoutes(companyId));
    
    print('🚀 [RouteService] Obteniendo rutas - GET $uri');
    
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    });

    print('📥 [RouteService] Response status: ${res.statusCode}');
    print('📥 [RouteService] Response body: ${res.body}');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        final list = decoded.cast<Map<String, dynamic>>();
        print('📦 [RouteService] Rutas recibidas: ${list.length}');
        for (var routeJson in list) {
          print('📍 [RouteService] Ruta: ${routeJson['routeId']} - Origen: ${routeJson['originProvinceName']}, ${routeJson['originDepartmentName']} - Destino: ${routeJson['destProvinceName']}, ${routeJson['destDepartmentName']}');
        }
        return list.map((j) => PlanningRoute.fromJson(j)).toList();
      }
      // Si no es una lista, retornar lista vacía
      return [];
    } else if (res.statusCode == 405 || res.statusCode == 500) {
      // Método no permitido o error del servidor - el endpoint GET podría no estar disponible
      print('⚠️ [RouteService] El endpoint GET no está disponible. Retornando lista vacía.');
      return []; // Retornar lista vacía en lugar de lanzar error
    }
    throw Exception('List routes failed: ${res.statusCode} ${res.body}');
  }

  Future<PlanningRoute> createRoute({
    required int companyId,
    required int routeTypeId,
    required String originDepartmentCode,
    required String originProvinceCode,
    required String destDepartmentCode,
    required String destProvinceCode,
    bool active = true,
  }) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) {
      print('❌ [RouteService] No hay sesión disponible');
      throw Exception('No hay sesión');
    }

    // Verificar si el token está expirado
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= session.expiresAt) {
      print('❌ [RouteService] Token expirado. ExpiresAt: ${session.expiresAt}, Now: $now');
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
    }

    final payload = {
      'routeTypeId': routeTypeId,
      'originDepartmentCode': originDepartmentCode,
      'destDepartmentCode': destDepartmentCode,
      'originProvinceCode': originProvinceCode,
      'destProvinceCode': destProvinceCode,
      'active': active,
    };

    final uri = Uri.parse(ApiConstants.companyRoutes(companyId));
    
    print('🚀 [RouteService] Creando ruta - POST $uri');
    print('📤 [RouteService] CompanyId: $companyId');
    print('📤 [RouteService] Payload: $payload');
    print('🔑 [RouteService] Token: ${session.accessToken.substring(0, 20)}...');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode(payload),
    );

    print('📥 [RouteService] Response status: ${res.statusCode}');
    print('📥 [RouteService] Response body: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      return PlanningRoute.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    
    // Mejor manejo de errores
    String errorMessage = 'Error al crear ruta';
    try {
      final errorBody = jsonDecode(res.body);
      if (errorBody is Map && errorBody.containsKey('message')) {
        errorMessage = errorBody['message'];
      } else if (errorBody is Map && errorBody.containsKey('error')) {
        errorMessage = errorBody['error'];
      } else {
        errorMessage = res.body;
      }
    } catch (e) {
      errorMessage = res.body;
    }
    
    if (res.statusCode == 401) {
      throw Exception('No autorizado. Tu sesión puede haber expirado. Por favor, inicia sesión nuevamente.');
    }
    
    throw Exception('Error al crear ruta (${res.statusCode}): $errorMessage');
  }

  Future<void> deleteRoute(int routeId) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse('${ApiConstants.baseUrl}/planning/routes/$routeId');
    final res = await http.delete(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    });

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete route failed: ${res.statusCode} ${res.body}');
    }
  }
}

