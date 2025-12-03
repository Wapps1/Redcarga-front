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
import '../models/change_dto.dart';
import '../models/driver_dto.dart';
import '../models/vehicle_dto.dart';
import '../models/assignment_dto.dart';
import '../models/checklist_item_dto.dart';
import '../models/pdf_upload_response.dart';
import '../models/guide_dto.dart';
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

  /// Obtiene las cotizaciones generales por company_id y state
  Future<List<QuoteDto>> getQuotesGeneral(
    int companyId,
    String state,
  ) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getQuotesGeneral(
        companyId,
        state,
        accessToken,
      );
    } catch (e) {
      print('❌ [DealsRepository] Error getting quotes general: $e');
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

  /// Crea una solicitud de aceptación de trato
  Future<void> createAcceptance(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.createAcceptance(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error creating acceptance: $e');
      rethrow;
    }
  }

  /// Confirma una aceptación de trato
  Future<void> confirmAcceptance(int quoteId, int acceptanceId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.confirmAcceptance(quoteId, acceptanceId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error confirming acceptance: $e');
      rethrow;
    }
  }

  /// Rechaza una aceptación de trato
  Future<void> rejectAcceptance(int quoteId, int acceptanceId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.rejectAcceptance(quoteId, acceptanceId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error rejecting acceptance: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles de un cambio propuesto
  Future<ChangeDto> getChange(int quoteId, int changeId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getChange(quoteId, changeId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting change: $e');
      rethrow;
    }
  }

  /// Acepta o rechaza un cambio propuesto
  Future<void> decideChange(
    int quoteId,
    int changeId,
    bool accept, {
    required String ifMatch,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.decideChange(
        quoteId,
        changeId,
        accept,
        accessToken,
        ifMatch: ifMatch,
      );
    } catch (e) {
      print('❌ [DealsRepository] Error deciding change: $e');
      rethrow;
    }
  }

  /// Obtiene los conductores de una empresa
  Future<List<DriverDto>> getDrivers(int companyId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getDrivers(companyId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting drivers: $e');
      rethrow;
    }
  }

  /// Obtiene los vehículos de una empresa
  Future<List<VehicleDto>> getVehicles(int companyId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getVehicles(companyId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting vehicles: $e');
      rethrow;
    }
  }

  /// Obtiene la asignación de flota y conductor para una cotización
  Future<AssignmentDto?> getAssignment(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getAssignment(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting assignment: $e');
      rethrow;
    }
  }

  /// Asigna o actualiza un conductor y un vehículo a un trato
  Future<void> assignFleetDriver(int quoteId, int driverId, int vehicleId) async {
    try {
      final accessToken = await _getAccessToken();
      
      // Obtener la asignación actual para obtener el version
      final currentAssignment = await _dealsService.getAssignment(quoteId, accessToken);
      final version = currentAssignment?.version ?? 0;
      
      return await _dealsService.assignFleetDriver(quoteId, driverId, vehicleId, version, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error assigning fleet and driver: $e');
      rethrow;
    }
  }

  /// Marca el pago como realizado
  Future<void> paymentMade(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.paymentMade(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error marking payment as made: $e');
      rethrow;
    }
  }

  /// Confirma el recibimiento del pago
  Future<void> paymentConfirm(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.paymentConfirm(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error confirming payment: $e');
      rethrow;
    }
  }

  /// Marca el envío como enviado
  Future<void> shipmentSent(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.shipmentSent(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error marking shipment as sent: $e');
      rethrow;
    }
  }

  /// Confirma el recibimiento del envío
  Future<void> shipmentReceived(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.shipmentReceived(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error confirming shipment received: $e');
      rethrow;
    }
  }

  /// Obtiene los items del checklist para una cotización
  Future<List<ChecklistItemDto>> getChecklistItems(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getChecklistItems(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting checklist items: $e');
      rethrow;
    }
  }

  /// Sube un archivo PDF al servidor
  Future<PdfUploadResponse> uploadPdf(String pdfPath) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.uploadPdf(pdfPath, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error uploading PDF: $e');
      rethrow;
    }
  }

  /// Obtiene las guías de remisión de una cotización
  Future<List<GuideDto>> getGuides(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getGuides(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting guides: $e');
      rethrow;
    }
  }

  /// Crea una nueva guía de remisión
  Future<void> createGuide(int quoteId, String type, String guideUrl) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.createGuide(quoteId, type, guideUrl, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error creating guide: $e');
      rethrow;
    }
  }

  /// Actualiza la URL de una guía existente
  Future<void> updateGuideUrl(int quoteId, int guideId, String guideUrl) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.updateGuideUrl(quoteId, guideId, guideUrl, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error updating guide URL: $e');
      rethrow;
    }
  }

  /// Obtiene la guía del transportista
  Future<GuideDto> getTransportistaGuide(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getTransportistaGuide(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting transportista guide: $e');
      rethrow;
    }
  }

  /// Obtiene la guía del remitente
  Future<GuideDto> getRemitenteGuide(int quoteId) async {
    try {
      final accessToken = await _getAccessToken();
      return await _dealsService.getRemitenteGuide(quoteId, accessToken);
    } catch (e) {
      print('❌ [DealsRepository] Error getting remitente guide: $e');
      rethrow;
    }
  }
}

