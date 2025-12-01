import '../services/deals_service.dart';
import '../models/request_dto.dart';
import '../models/request_detail_dto.dart';
import '../models/quote_dto.dart';
import '../models/quote_detail_dto.dart';
import '../models/quote_version_dto.dart';

class DealsRepository {
  final DealsService _dealsService;
  final Future<String> Function() _getAccessToken;

  DealsRepository({
    required DealsService dealsService,
    required Future<String> Function() getAccessToken,
  })  : _dealsService = dealsService,
        _getAccessToken = getAccessToken;

  /// Obtiene todas las solicitudes del usuario
  Future<List<RequestDto>> getRequests() async {
    try {
      print('🔑 [DealsRepository] Obteniendo access token...');
      final accessToken = await _getAccessToken();
      print('✅ [DealsRepository] Token obtenido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
      return await _dealsService.getRequests(accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting requests: $e');
      rethrow;
    }
  }

  /// Obtiene las cotizaciones para una solicitud específica
  Future<List<QuoteDto>> getQuotesByRequestId(
    int requestId, {
    String? state,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getQuotesByRequestId(
        requestId,
        accessToken,
        state: state,
      );
    } catch (e) {
      print('❌ [DealsRepository] Error getting quotes: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles de una cotización específica
  Future<QuoteDetailDto> getQuoteDetail(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getQuoteDetail(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting quote detail: $e');
      rethrow;
    }
  }

  /// Obtiene el detalle de una solicitud específica
  Future<RequestDetailDto> getRequestDetail(int requestId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getRequestDetail(requestId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting request detail: $e');
      rethrow;
    }
  }

  /// Inicia la negociación de una cotización
  Future<void> startNegotiation(
    int quoteId, {
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.startNegotiation(
        quoteId,
        accessToken,
        ifMatch: ifMatch,
        idempotencyKey: idempotencyKey,
      );
    } catch (e) {
      print('❌ [DealsRepository] Error starting negotiation: $e');
      rethrow;
    }
  }

  /// Obtiene la versión de una cotización
  Future<QuoteVersionDto> getQuoteVersion(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getQuoteVersion(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting quote version: $e');
      rethrow;
    }
  }

  /// Rechaza una cotización
  Future<void> rejectQuote(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.rejectQuote(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error rejecting quote: $e');
      rethrow;
    }
  }
}

