import '../services/deals_service.dart';
import '../models/request_dto.dart';
import '../models/request_detail_dto.dart';
import '../models/quote_dto.dart';
import '../models/quote_detail_dto.dart';
import '../models/quote_version_dto.dart';
import '../models/company_dto.dart';
import '../models/chat_list_dto.dart';
import '../models/chat_dto.dart';
import '../models/quote_change_request_dto.dart';
import '../../../requests/data/models/image_upload_response.dart';

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

  /// Obtiene la información de una empresa por su ID
  Future<CompanyDto> getCompany(int companyId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getCompany(companyId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting company: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de chats del usuario
  Future<ChatListDto> getChatList() async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getChatList(accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting chat list: $e');
      rethrow;
    }
  }

  /// Obtiene los mensajes de un chat específico
  Future<ChatDto> getChat(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getChat(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting chat: $e');
      rethrow;
    }
  }

  /// Sube una imagen a Cloudinary
  Future<ImageUploadResponse> uploadImage(String imagePath) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.uploadImage(imagePath, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error uploading image: $e');
      rethrow;
    }
  }

  /// Envía un mensaje de texto al chat
  Future<void> sendTextMessage(int quoteId, String text) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.sendTextMessage(quoteId, text, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error sending text message: $e');
      rethrow;
    }
  }

  /// Envía un mensaje de imagen al chat
  Future<void> sendImageMessage(int quoteId, String imageUrl, {String? caption}) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.sendImageMessage(quoteId, imageUrl, caption, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error sending image message: $e');
      rethrow;
    }
  }

  /// Marca los mensajes como leídos
  Future<void> markMessagesAsRead(int quoteId, int lastSeenMessageId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.markMessagesAsRead(quoteId, lastSeenMessageId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Aplica cambios a una cotización
  Future<void> applyQuoteChanges(
    int quoteId,
    QuoteChangeRequestDto changes, {
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.applyQuoteChanges(
        quoteId,
        changes,
        accessToken,
        ifMatch: ifMatch,
        idempotencyKey: idempotencyKey,
      );
    } catch (e) {
      print('❌ [DealsRepository] Error applying quote changes: $e');
      rethrow;
    }
  }
}

