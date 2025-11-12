import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//import 'package:red_carga/core/constants/api_constants.dart';
import 'package:red_carga/costants/api_constants.dart';


class VehicleService {
  final http.Client _client;
  VehicleService({http.Client? client}) : _client = client ?? http.Client();

  /// GET /fleet/vehicles/{vehicleId}
  Future<Map<String, dynamic>> getVehicleById(int vehicleId) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.vehicleById(vehicleId));
    final res = await _client.get(uri);
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw 'Error ${res.statusCode}: ${res.body}';
  }

  /// GET /fleet/companies/{companyId}/vehicles
  Future<List<dynamic>> listVehiclesByCompany(int companyId) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.companyVehicles(companyId));
    final res = await _client.get(uri);
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw 'Error ${res.statusCode}: ${res.body}';
  }

  /// POST /fleet/companies/{companyId}/vehicles
  Future<Map<String, dynamic>> createVehicle({
    required int companyId,
    required String name,
    required String plate,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.companyVehicles(companyId));
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'plate': plate,
      }),
    );
    if (res.statusCode == HttpStatus.ok || res.statusCode == HttpStatus.created) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw 'Error ${res.statusCode}: ${res.body}';
  }

  /// PUT /fleet/vehicles/{vehicleId}
  Future<Map<String, dynamic>> updateVehicle({
    required int vehicleId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.vehicleById(vehicleId));
    final res = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw 'Error ${res.statusCode}: ${res.body}';
  }

  /// DELETE /fleet/vehicles/{vehicleId}
  Future<void> deleteVehicle(int vehicleId) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.vehicleById(vehicleId));
    final res = await _client.delete(uri);
    if (res.statusCode == HttpStatus.noContent || res.statusCode == HttpStatus.ok) return;
    throw 'Error ${res.statusCode}: ${res.body}';
  }
}
