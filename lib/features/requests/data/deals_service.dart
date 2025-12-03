import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../costants/api_constants.dart';
import '../../../core/session/session_store.dart';

class DealsService {
  final http.Client _client;
  final SessionStore _sessionStore;

  DealsService({
    http.Client? client,
    SessionStore? sessionStore,
  })  : _client = client ?? http.Client(),
        _sessionStore = sessionStore ?? SessionStore();

  /// Crea una cotización
  Future<Map<String, dynamic>> createQuote({
    required int requestId,
    required int companyId,
    required double totalAmount,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse(ApiConstants.createQuoteEndpoint);
    
    final appSession = await _sessionStore.getAppSession();
    
    if (appSession == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión nuevamente.');
    }

    final token = appSession.accessToken;
    if (token.isEmpty) {
      throw Exception('Token de acceso no disponible.');
    }

    // Verificar si el token está expirado
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= appSession.expiresAt) {
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
    }

    final body = jsonEncode({
      'requestId': requestId,
      'companyId': companyId,
      'totalAmount': totalAmount,
      'currency': currency,
      'items': items,
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '${appSession.tokenType.value} $token',
    };

    print('🚀 [DealsService] Create Quote - POST $url');
    print('📤 [DealsService] Request body: $body');

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

      print('📥 [DealsService] Response status: ${response.statusCode}');
      print('📥 [DealsService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          return {'success': true};
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(_parseError(response, 'Error al crear cotización'));
      }
    } catch (e) {
      print('❌ [DealsService] Error: $e');
      rethrow;
    }
  }

  /// Rechaza una cotización
  Future<void> rejectQuote(int quoteId) async {
    final url = Uri.parse(ApiConstants.rejectQuote(quoteId));
    
    final appSession = await _sessionStore.getAppSession();
    
    if (appSession == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión nuevamente.');
    }

    final token = appSession.accessToken;
    if (token.isEmpty) {
      throw Exception('Token de acceso no disponible.');
    }

    // Verificar si el token está expirado
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= appSession.expiresAt) {
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': '${appSession.tokenType.value} $token',
    };

    print('🚀 [DealsService] Reject Quote - POST $url');

    try {
      final response = await _client.post(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 30 segundos');
        },
      );

      print('📥 [DealsService] Response status: ${response.statusCode}');
      print('📥 [DealsService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [DealsService] Cotización rechazada exitosamente');
        return;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(_parseError(response, 'Error al rechazar cotización'));
      }
    } catch (e) {
      print('❌ [DealsService] Error: $e');
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


