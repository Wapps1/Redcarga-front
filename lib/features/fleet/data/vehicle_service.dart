import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/fleet/domain/vehicle.dart';

class VehicleService {
  Future<Map<String, String>> _headers() async {
    final app = await SessionStore().getAppSession();
    return {
      'Content-Type': 'application/json',
      if (app != null) 'Authorization': '${app.tokenType.value} ${app.accessToken}',
    };
  }

  Vehicle _fromJson(Map<String, dynamic> j) => Vehicle(
        vehicleId: j['vehicleId'] as int,
        name: j['name'] as String,
        plate: j['plate'] as String,
      );

  Map<String, dynamic> _toJson({required String name, required String plate}) => {
        'name': name,
        'plate': plate,
      };

  // GET /fleet/companies/{companyId}/vehicles
  Future<List<Vehicle>> listByCompany({required int companyId}) async {
    final uri = Uri.parse(ApiConstants.companyVehicles(companyId));
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = (body is List) ? body : (body['items'] ?? body['results'] ?? []);
      return data.map((e) => _fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('List vehicles failed: ${res.statusCode} ${res.body}');
  }

  // GET /fleet/vehicles/{vehicleId}
  Future<Vehicle> getById(int vehicleId) async {
    final uri = Uri.parse(ApiConstants.vehicleById(vehicleId));
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return _fromJson(jsonDecode(res.body));
    }
    throw Exception('Get vehicle failed: ${res.statusCode} ${res.body}');
  }

  // POST /fleet/companies/{companyId}/vehicles
  Future<Vehicle> create({
    required int companyId,
    required String name,
    required String plate,
  }) async {
    final uri = Uri.parse(ApiConstants.companyVehicles(companyId));
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(_toJson(name: name, plate: plate)),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return _fromJson(jsonDecode(res.body));
    }
    throw Exception('Create vehicle failed: ${res.statusCode} ${res.body}');
  }

  // PUT /fleet/vehicles/{vehicleId}
  Future<Vehicle> update({
    required int vehicleId,
    required String name,
    required String plate,
  }) async {
    final uri = Uri.parse(ApiConstants.vehicleById(vehicleId));
    final res = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(_toJson(name: name, plate: plate)),
    );
    if (res.statusCode == 200) {
      return _fromJson(jsonDecode(res.body));
    }
    throw Exception('Update vehicle failed: ${res.statusCode} ${res.body}');
  }

  // DELETE /fleet/vehicles/{vehicleId}
  Future<void> delete(int vehicleId) async {
    final uri = Uri.parse(ApiConstants.vehicleById(vehicleId));
    final res = await http.delete(uri, headers: await _headers());
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Delete vehicle failed: ${res.statusCode} ${res.body}');
  }
}
