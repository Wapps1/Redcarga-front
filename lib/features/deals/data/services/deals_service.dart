import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../costants/api_constants.dart';
import '../models/request_dto.dart';
import '../models/request_detail_dto.dart';
import '../models/quote_dto.dart';
import '../models/quote_detail_dto.dart';
import '../models/quote_version_dto.dart';

class DealsService {
  final http.Client _client;

  DealsService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene todas las solicitudes del usuario
  Future<List<RequestDto>> getRequests(String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/requests');
    
    print('🚀 [DealsService] GET $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    print('📤 [DealsService] Headers: Authorization: Bearer ${accessToken.substring(0, 20)}...');
    
    try {
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
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('📥 [DealsService] Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => RequestDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(_parseError(response, 'Failed to get requests'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting requests: $e');
      rethrow;
    }
  }

  /// Obtiene las cotizaciones para una solicitud específica
  Future<List<QuoteDto>> getQuotesByRequestId(
    int requestId,
    String accessToken, {
    String? state,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes');
    final url = uri.replace(queryParameters: {
      'requestId': requestId.toString(),
      if (state != null) 'state': state,
    });
    
    print('🚀 [DealsService] GET $url');
    
    try {
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
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => QuoteDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(_parseError(response, 'Failed to get quotes'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting quotes: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles de una cotización específica
  Future<QuoteDetailDto> getQuoteDetail(
    int quoteId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/detail');
    
    print('🚀 [DealsService] GET $url');
    
    try {
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
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return QuoteDetailDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception(_parseError(response, 'Failed to get quote detail'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting quote detail: $e');
      rethrow;
    }
  }

  /// Obtiene el detalle de una solicitud específica
  Future<RequestDetailDto> getRequestDetail(
    int requestId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/requests/$requestId');
    
    print('🚀 [DealsService] GET $url');
    
    try {
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
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return RequestDetailDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception(_parseError(response, 'Failed to get request detail'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting request detail: $e');
      rethrow;
    }
  }

  /// Inicia la negociación de una cotización
  Future<void> startNegotiation(
    int quoteId,
    String accessToken, {
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId:start-negotiation');
    
    print('🚀 [DealsService] POST $url');
    
    try {
      final headers = <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'If-Match': ifMatch,
      };
      
      if (idempotencyKey != null) {
        headers['Idempotency-Key'] = idempotencyKey;
      }
      
      final response = await _client.post(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception(_parseError(response, 'Failed to start negotiation'));
      }
    } catch (e) {
      print('❌ [DealsService] Error starting negotiation: $e');
      rethrow;
    }
  }

  /// Obtiene la versión de una cotización
  Future<QuoteVersionDto> getQuoteVersion(
    int quoteId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/version');
    
    print('🚀 [DealsService] GET $url');
    
    try {
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
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return QuoteVersionDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception(_parseError(response, 'Failed to get quote version'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting quote version: $e');
      rethrow;
    }
  }

  /// Rechaza una cotización
  Future<void> rejectQuote(
    int quoteId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId:reject');
    
    print('🚀 [DealsService] POST $url');
    
    try {
      final response = await _client.post(
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
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      // 204 No Content es una respuesta exitosa (el recurso fue eliminado)
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_parseError(response, 'Failed to reject quote'));
      }
    } catch (e) {
      print('❌ [DealsService] Error rejecting quote: $e');
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
      return 'Error ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}';
    }
  }
}

