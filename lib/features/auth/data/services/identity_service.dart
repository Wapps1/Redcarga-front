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
    final endpoint = ApiConstants.verifyAndCreatePersonEndpoint;
    final finalEndpoint = endpoint.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    final url = Uri.parse(finalEndpoint);
    final body = jsonEncode(request.toJson());
    
    print('👤 [IdentityService] Verify and Create Person - POST $url');
    print('📤 [IdentityService] Request body: $body');
    print('🔑 [IdentityService] Firebase token: ${firebaseIdToken.substring(0, 20)}...');
    
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // NO incluir 'X-Firebase-Auth' - puede causar problemas en Android
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: body,
    );

    print('📥 [IdentityService] Response status: ${response.statusCode}');
    print('📥 [IdentityService] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PersonCreateResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Intentar parsear el error como JSON
      String errorMessage = 'Failed to create person: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          errorMessage = errorBody?['message'] ?? 
              errorBody?['error'] ?? 
              errorBody?['detail'] ??
              errorMessage;
        } catch (e) {
          // Si no es JSON, usar el body directamente
          if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
            errorMessage = 'Backend returned HTML (${response.statusCode}). Check if the backend is running at $finalEndpoint';
          } else {
            errorMessage = 'Error ${response.statusCode}: ${response.body}';
          }
        }
      }
      throw Exception('Failed to create person: $errorMessage');
    }
  }
}

