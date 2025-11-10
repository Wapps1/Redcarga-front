import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../costants/api_constants.dart';
import '../models/company_register_request_dto.dart';
import '../models/company_register_response_dto.dart';

class ProviderService {
  final http.Client _client;

  ProviderService({http.Client? client}) : _client = client ?? http.Client();

  Future<CompanyRegisterResponseDto> registerCompany(
    CompanyRegisterRequestDto request,
    String firebaseIdToken,
  ) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.registerCompanyEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'X-Firebase-Auth': 'true',
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompanyRegisterResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to register company: ${response.statusCode}');
    }
  }
}

