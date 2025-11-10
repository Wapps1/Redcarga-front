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
    final response = await _client.post(
      Uri.parse(ApiConstants.registerStartEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterStartResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  Future<AppLoginResponseDto> login(
    AppLoginRequestDto request,
    String firebaseIdToken,
  ) async {
    // Asegurar que usamos la URL correcta (10.0.2.2 para emulador, no localhost)
    final endpoint = ApiConstants.loginEndpoint;
    print('🔗 [AuthService] Login endpoint desde constante: $endpoint');
    print('🔗 [AuthService] Base URL: ${ApiConstants.baseUrl}');
    
    // Forzar uso de 10.0.2.2 si aparece localhost
    final finalEndpoint = endpoint.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    if (finalEndpoint != endpoint) {
      print('⚠️ [AuthService] URL corregida de localhost a 10.0.2.2: $finalEndpoint');
    }
    
    final url = Uri.parse(finalEndpoint);
    final body = jsonEncode(request.toJson());
    
    print('🌐 [AuthService] POST ${url}');
    print('📤 [AuthService] Headers: Authorization: Bearer ${firebaseIdToken.substring(0, 20)}..., Content-Type: application/json');
    print('📤 [AuthService] Body: $body');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // NO incluir 'X-Firebase-Auth' - el interceptor en Android lo remueve
          // Solo enviar Authorization header
          'Authorization': 'Bearer $firebaseIdToken',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos. Verifica que esté corriendo en $finalEndpoint');
        },
      );
      
      print('📥 [AuthService] Response status: ${response.statusCode}');
      print('📥 [AuthService] Response headers: ${response.headers}');
      print('📥 [AuthService] Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      if (response.statusCode == 200) {
      // Verificar que la respuesta sea JSON, no HTML
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
      // Intentar parsear el error como JSON
      String errorMessage = 'Failed to login: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          errorMessage = errorBody?['message'] ?? 
              errorBody?['error'] ?? 
              errorMessage;
        } catch (e) {
          // Si no es JSON, puede ser HTML o texto plano
          if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
            errorMessage = 'Backend returned HTML (${response.statusCode}). Check if the backend is running at ${ApiConstants.loginEndpoint}';
          } else {
            errorMessage = 'Error ${response.statusCode}: ${response.body.substring(0, 200)}';
          }
        }
      }
      throw Exception(errorMessage);
    }
    } catch (e) {
      // Manejar errores de conexión, timeout, etc.
      if (e.toString().contains('Timeout')) {
        rethrow;
      }
      if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        throw Exception('No se puede conectar al backend en $finalEndpoint. Verifica que el backend esté corriendo y accesible desde el emulador.');
      }
      rethrow;
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

