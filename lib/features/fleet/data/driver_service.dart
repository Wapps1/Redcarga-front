// lib/features/fleet/data/services/driver_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/core/session/session_store.dart';
import '../domain/driver.dart';

class DriverService {
  final SessionStore _sessionStore;
  DriverService(this._sessionStore);

  Future<List<Driver>> getDrivers({required int companyId}) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.companyDrivers(companyId));
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    });

    if (res.statusCode == 200) {
      final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      return list.map((j) => Driver.fromJson(j)).toList();
    }
    throw Exception('List drivers failed: ${res.statusCode} ${res.body}');
  }

  Future<Driver> getDriver(int driverId) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.driverById(driverId));
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    });

    if (res.statusCode == 200) {
      return Driver.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Get driver failed: ${res.statusCode} ${res.body}');
  }

  Future<Driver> createDriver({
    required int companyId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String licenseNumber,
    bool active = true,
  }) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) {
      print('❌ [DriverService] No hay sesión disponible');
      throw Exception('No hay sesión');
    }

    // Verificar si el token está expirado
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= session.expiresAt) {
      print('❌ [DriverService] Token expirado. ExpiresAt: ${session.expiresAt}, Now: $now');
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
    }

    final payload = {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'phone': phone.replaceAll(RegExp(r'\D'), ''),
      'licenseNumber': licenseNumber.trim(),
      'active': active,
    };

    final uri = Uri.parse(ApiConstants.companyDrivers(companyId));
    
    print('🚀 [DriverService] Creando conductor - POST $uri');
    print('📤 [DriverService] CompanyId: $companyId');
    print('📤 [DriverService] Payload: $payload');
    print('🔑 [DriverService] Token: ${session.accessToken.substring(0, 20)}...');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode(payload),
    );

    print('📥 [DriverService] Response status: ${res.statusCode}');
    print('📥 [DriverService] Response body: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      return Driver.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    
    // Mejor manejo de errores
    String errorMessage = 'Error al crear conductor';
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
    
    throw Exception('Error al crear conductor (${res.statusCode}): $errorMessage');
  }

  Future<void> deleteDriver(int driverId) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.driverById(driverId));
    final res = await http.delete(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    });

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete driver failed: ${res.statusCode} ${res.body}');
    }
  }
}
