import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_carga/costants/api_constants.dart';

class DriverIdentityService {
  final http.Client httpClient;

  DriverIdentityService({required this.httpClient});

  Future<Map<String, dynamic>> getIdentity({
    required int accountId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(ApiConstants.identityByAccount(accountId));

    final response = await httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Error al obtener identidad (status: ${response.statusCode})',
    );
  }
}