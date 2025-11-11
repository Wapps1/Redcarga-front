import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../costants/api_constants.dart';
import '../models/register_start_request_dto.dart';
import '../models/register_start_response_dto.dart';
import '../models/app_login_request_dto.dart';
import '../models/app_login_response_dto.dart';
import '../models/firebase_sign_in_request_dto.dart';
import '../models/firebase_sign_in_response_dto.dart';

class AuthService {
  final http.Client _client;
  static const String _firebaseBaseUrl = 'https://identitytoolkit.googleapis.com';
  static const String _firebaseApiKey = 'AIzaSyCg6E_E0KeZqtmTGccKVQg64surOnjhQ-M';

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<RegisterStartResponseDto> registerStart(
    RegisterStartRequestDto request,
  ) async {
    final url = Uri.parse(ApiConstants.registerStartEndpoint);
    final body = jsonEncode(request.toJson());
    
    print('🚀 [AuthService] Register Start - POST $url');
    print('📤 [AuthService] Request body: $body');
    
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('📥 [AuthService] Response status: ${response.statusCode}');
    print('📥 [AuthService] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterStartResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(_parseError(response, 'Failed to register'));
    }
  }

  Future<AppLoginResponseDto> login(
    AppLoginRequestDto request,
    String firebaseIdToken,
  ) async {
    final url = Uri.parse(ApiConstants.loginEndpoint);
    final body = jsonEncode(request.toJson());
    
    print('🌐 [AuthService] POST $url');
    print('📤 [AuthService] Headers: Authorization: Bearer ${firebaseIdToken.substring(0, 20)}..., Content-Type: application/json');
    print('📤 [AuthService] Body: $body');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos. Verifica que esté corriendo en ${ApiConstants.loginEndpoint}');
        },
      );
      
      print('📥 [AuthService] Response status: ${response.statusCode}');
      print('📥 [AuthService] Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          throw Exception('Backend returned HTML instead of JSON. Check if the backend is running at ${ApiConstants.loginEndpoint}');
        }
        
        try {
          return AppLoginResponseDto.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
        } catch (e) {
          throw Exception('Failed to parse login response: $e. Response body: ${response.body.substring(0, 200)}');
        }
      } else {
        throw Exception(_parseError(response, 'Failed to login'));
      }
    } catch (e) {
      if (e.toString().contains('Timeout')) {
        rethrow;
      }
      if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        throw Exception('No se puede conectar al backend en ${ApiConstants.loginEndpoint}. Verifica que el backend esté corriendo y accesible.');
      }
      rethrow;
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

  /// Autenticación con Firebase usando REST API (igual que en Android)
  Future<FirebaseSignInResponseDto> firebaseSignInWithPassword(
    FirebaseSignInRequestDto request,
  ) async {
    final url = Uri.parse(
      '$_firebaseBaseUrl/v1/accounts:signInWithPassword?key=$_firebaseApiKey',
    );

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return FirebaseSignInResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMessage = errorBody['error']?['message'] ?? 'Error desconocido';
      throw Exception('Firebase auth error: $errorMessage');
    }
  }
}

