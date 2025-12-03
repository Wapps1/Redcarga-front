import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../costants/api_constants.dart';
import '../models/person_create_request_dto.dart';
import '../models/person_create_response_dto.dart';
import '../models/user_identity_dto.dart';

class IdentityService {
  final http.Client _client;

  IdentityService({http.Client? client}) : _client = client ?? http.Client();

  Future<PersonCreateResponseDto> verifyAndCreate(
    PersonCreateRequestDto request,
    String firebaseIdToken,
  ) async {
    final url = Uri.parse(ApiConstants.verifyAndCreatePersonEndpoint);
    final body = jsonEncode(request.toJson());
    
    print('👤 [IdentityService] Verify and Create Person - POST $url');
    print('📤 [IdentityService] Request body: $body');
    print('🔑 [IdentityService] Firebase token: ${firebaseIdToken.substring(0, 20)}...');
    
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
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
      throw Exception(_parseError(response, 'Failed to create person'));
    }
  }
  
  /// Obtiene los datos de identidad de un usuario por su accountId
  Future<UserIdentityDto> getUserIdentity(int accountId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/identity/$accountId');
    
    print('👤 [IdentityService] Get User Identity - GET $url');
    
    final response = await _client.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Timeout: El backend no respondió en 10 segundos');
      },
    );

    print('📥 [IdentityService] Response status: ${response.statusCode}');
    print('📥 [IdentityService] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return UserIdentityDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(_parseError(response, 'Failed to get user identity'));
    }
  }
  
  String _parseError(http.Response response, String defaultMessage) {
    if (response.body.isEmpty) {
      return '$defaultMessage: ${response.statusCode}';
    }
    
    try {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
      return errorBody?['message'] ?? 
          errorBody?['error'] ?? 
          errorBody?['detail'] ??
          '$defaultMessage: ${response.statusCode}';
    } catch (e) {
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
        return 'Backend returned HTML (${response.statusCode}). Check if the backend is running at ${response.request?.url}';
      }
      return 'Error ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}';
    }
  }
}

