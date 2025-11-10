import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../costants/api_constants.dart';
import '../models/person_create_request_dto.dart';
import '../models/person_create_response_dto.dart';

class IdentityService {
  final http.Client _client;

  IdentityService({http.Client? client}) : _client = client ?? http.Client();

  Future<PersonCreateResponseDto> verifyAndCreate(
    PersonCreateRequestDto request,
    String firebaseIdToken,
  ) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.verifyAndCreatePersonEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'X-Firebase-Auth': 'true',
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PersonCreateResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create person: ${response.statusCode}');
    }
  }
}

