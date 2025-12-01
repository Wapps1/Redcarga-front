import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../costants/api_constants.dart';
import 'models/create_request_dto.dart';
import '../../../core/session/session_store.dart';

class RequestsService {
  final http.Client _client;
  final SessionStore _sessionStore;

  RequestsService({
    http.Client? client,
    SessionStore? sessionStore,
  })  : _client = client ?? http.Client(),
        _sessionStore = sessionStore ?? SessionStore();

  /// Crea una nueva solicitud
  Future<Map<String, dynamic>> createRequest(CreateRequestDto request) async {
    final url = Uri.parse(ApiConstants.createRequestEndpoint);
    final body = request.toJsonString();
    
    // Obtener token de sesión si está disponible
    final appSession = await _sessionStore.getAppSession();
    
    print('🔑 [RequestsService] Verificando autenticación...');
    if (appSession == null) {
      print('❌ [RequestsService] No hay sesión activa');
      throw Exception('No hay sesión activa. Por favor inicia sesión nuevamente.');
    }
    
    final token = appSession.accessToken;
    if (token.isEmpty) {
      print('❌ [RequestsService] Token de acceso no disponible');
      throw Exception('Token de acceso no disponible. Por favor inicia sesión nuevamente.');
    }
    
    // Verificar si el token está expirado
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= appSession.expiresAt) {
      print('❌ [RequestsService] Token expirado. ExpiresAt: ${appSession.expiresAt}, Now: $now');
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
    }
    
    print('✅ [RequestsService] Token encontrado: ${token.substring(0, 20)}...');
    print('✅ [RequestsService] TokenType: ${appSession.tokenType.value}');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '${appSession.tokenType.value} $token',
    };
    
    print('🚀 [RequestsService] Create Request - POST $url');
    print('📤 [RequestsService] Headers: Authorization: Bearer ${token.substring(0, 20)}...');
    print('📤 [RequestsService] Request body: $body');
    
    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 30 segundos');
        },
      );
      
      print('📥 [RequestsService] Response status: ${response.statusCode}');
      print('📥 [RequestsService] Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty) {
          return {'success': true, 'message': 'Solicitud creada exitosamente'};
        }
        
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          return {'success': true, 'message': 'Solicitud creada exitosamente'};
        }
      } else if (response.statusCode == 401) {
        print('❌ [RequestsService] Error 401 - No autorizado');
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(_parseError(response, 'Failed to create request'));
      }
    } catch (e) {
      print('❌ [RequestsService] Error: $e');
      rethrow;
    }
  }

  String _parseError(http.Response response, String defaultMessage) {
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      return errorJson['message'] as String? ?? 
             errorJson['error'] as String? ?? 
             defaultMessage;
    } catch (e) {
      return '$defaultMessage: ${response.statusCode} - ${response.body}';
    }
  }
}

