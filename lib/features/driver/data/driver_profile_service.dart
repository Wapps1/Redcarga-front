import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_carga/costants/api_constants.dart';

class DriverService {
  final http.Client httpClient;

  DriverService({required this.httpClient});

  Future<Map<String, dynamic>> getDriverById({
    required int driverId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(ApiConstants.driverById(driverId));

    final response = await httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error al obtener driver (status: ${response.statusCode})',
      );
    }
  }
}