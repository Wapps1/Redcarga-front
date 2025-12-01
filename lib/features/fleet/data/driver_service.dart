import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/fleet/domain/driver.dart';

class DriverService {
  final SessionStore _sessionStore;
  DriverService(this._sessionStore);

  Future<List<Driver>> getDrivers({required int companyId}) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.companyDrivers(companyId));

    print('🚚 [DriverService] GET drivers - $uri');
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': '${session.tokenType.value} ${session.accessToken}',
    });

    print('📥 [DriverService] GET status: ${res.statusCode}');
    print('📥 [DriverService] GET body: ${res.body}');

    if (res.statusCode == 200) {
      final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      return list.map(Driver.fromJson).toList();
    }

    throw Exception('List drivers failed: ${res.statusCode} ${res.body}');
  }

  Future<void> createDriver({
    required int companyId,
    required int accountId,
    required String licenseNumber,
    bool active = true,
    String? plateImageUrl,
  }) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.companyDrivers(companyId));

    final payload = <String, dynamic>{
      'accountId': accountId,
      'licenseNumber': licenseNumber,
      'active': active,
      if (plateImageUrl != null && plateImageUrl.isNotEmpty)
        'licenseImageUrl': plateImageUrl,
    };

    print('🚚 [DriverService] POST create driver - $uri');
    print('📤 [DriverService] Payload: $payload');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': '${session.tokenType.value} ${session.accessToken}',
      },
      body: jsonEncode(payload),
    );

    print('📥 [DriverService] POST status: ${res.statusCode}');
    print('📥 [DriverService] POST body: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    }

    if (res.statusCode == 422) {
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final code = (body['code'] ?? body['error'])?.toString();
        final detail = (body['message'] ?? body['detail'])?.toString();
        if (code == 'company_not_found') {
          throw Exception('La empresa indicada no existe.');
        }
        throw Exception(detail ?? 'Validación rechazada por el backend.');
      } catch (_) {
        throw Exception('Solicitud inválida (422).');
      }
    }

    String backendMessage = res.body;
    try {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      backendMessage = decoded['message']?.toString() ?? backendMessage;
    } catch (_) {}

    throw Exception(
      'Create driver failed (${res.statusCode}): $backendMessage',
    );
  }

  Future<void> deleteDriver(int driverId) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.driverById(driverId));
    final res = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': '${session.tokenType.value} ${session.accessToken}',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) return;

    String backendMessage = res.body;
    try {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      backendMessage = decoded['message']?.toString() ?? backendMessage;
    } catch (_) {}

    throw Exception(
      'Delete driver failed (${res.statusCode}): $backendMessage',
    );
  }
}