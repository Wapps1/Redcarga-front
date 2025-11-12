import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//import 'package:red_carga/core/constants/api_constants.dart';
import 'package:red_carga/costants/api_constants.dart';

class DriverService {
  final http.Client _client;
  DriverService({http.Client? client}) : _client = client ?? http.Client();

  /// GET /fleet/drivers/{driverId}
  Future<Map<String, dynamic>> getDriverById(int driverId) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.driverById(driverId));
    final res = await _client.get(uri);
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw 'Error ${res.statusCode}: ${res.body}';
  }

  /// GET /fleet/companies/{companyId}/drivers
  Future<List<dynamic>> listDriversByCompany(int companyId) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.companyDrivers(companyId));
    final res = await _client.get(uri);
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw 'Error ${res.statusCode}: ${res.body}';
  }

  /// POST /fleet/companies/{companyId}/drivers
  /// Si envías [licenseImage], usa multipart; si no, envía JSON simple.
  Future<Map<String, dynamic>> createDriver({
    required int companyId,
    required String name,
    required String dni,
    required String phone,
    File? licenseImage,
  }) async {
    final base = Uri.parse(ApiConstants.baseUrl);

    if (licenseImage != null) {
      final uri = base.replace(path: ApiConstants.companyDrivers(companyId));
      final request = http.MultipartRequest('POST', uri)
        ..fields['name'] = name
        ..fields['dni'] = dni
        ..fields['phone'] = phone
        ..files.add(await http.MultipartFile.fromPath('licenseImage', licenseImage.path));
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == HttpStatus.ok || streamed.statusCode == HttpStatus.created) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      throw 'Error ${streamed.statusCode}: $body';
    } else {
      final uri = base.replace(path: ApiConstants.companyDrivers(companyId));
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'dni': dni,
          'phone': phone,
        }),
      );
      if (res.statusCode == HttpStatus.ok || res.statusCode == HttpStatus.created) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw 'Error ${res.statusCode}: ${res.body}';
    }
  }

  /// PUT /fleet/drivers/{driverId}
  /// [payload] debe contener solo los campos a actualizar (p. ej. name/phone/dni/..).
  Future<Map<String, dynamic>> updateDriver({
    required int driverId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.driverById(driverId));
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

  /// DELETE /fleet/drivers/{driverId}
  Future<void> deleteDriver(int driverId) async {
    final uri = Uri.parse(ApiConstants.baseUrl)
        .replace(path: ApiConstants.driverById(driverId));
    final res = await _client.delete(uri);
    if (res.statusCode == HttpStatus.noContent || res.statusCode == HttpStatus.ok) return;
    throw 'Error ${res.statusCode}: ${res.body}';
  }
}
