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
    if (session == null) throw Exception('No hay sesión');

    final payload = {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'phone': phone.replaceAll(RegExp(r'\D'), ''),
      'licenseNumber': licenseNumber.trim(),
      'active': active,
    };

    final uri = Uri.parse(ApiConstants.companyDrivers(companyId)); // <- lista de la empresa
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return Driver.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Create driver failed: ${res.statusCode} ${res.body}');
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
