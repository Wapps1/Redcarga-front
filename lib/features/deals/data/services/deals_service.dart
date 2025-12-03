import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../costants/api_constants.dart';
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
import '../../../requests/data/models/image_upload_response.dart';

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

  /// Obtiene la información de una empresa por su ID
  Future<CompanyDto> getCompany(int companyId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/providers/company/$companyId');
    
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
      if (response.statusCode != 200) {
        print('📥 [DealsService] Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CompanyDto.fromJson(json);
      } else {
        throw Exception(_parseError(response, 'Failed to get company'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting company: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de chats del usuario
  /// Nota: El endpoint tiene {quoteId} en la URL pero no es un parámetro que se reemplace
  /// El backend devuelve todos los chats del usuario
  Future<ChatListDto> getChatList(String accessToken) async {
    // El endpoint tiene {quoteId} en la URL pero según el usuario no es un parámetro
    // Probamos primero sin el {quoteId} ya que devuelve múltiples chats
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/chat/list');
    
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
      if (response.statusCode != 200) {
        print('📥 [DealsService] Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ChatListDto.fromJson(json);
      } else {
        throw Exception(_parseError(response, 'Failed to get chat list'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting chat list: $e');
      rethrow;
    }
  }

  /// Obtiene los mensajes de un chat específico
  Future<ChatDto> getChat(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/chat');
    
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
      if (response.statusCode != 200) {
        print('📥 [DealsService] Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ChatDto.fromJson(json);
      } else {
        throw Exception(_parseError(response, 'Failed to get chat'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting chat: $e');
      rethrow;
    }
  }

  /// Sube una imagen a Cloudinary
  Future<ImageUploadResponse> uploadImage(String imagePath, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/media/uploads:image');
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('El archivo de imagen no existe: $imagePath');
    }

    print('📤 [DealsService] Subiendo imagen: $imagePath');

    // Obtener extensión del archivo y determinar tipo MIME
    final fileName = imagePath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final contentType = _getContentType(extension);

    if (contentType == null) {
      throw Exception('Tipo de archivo no soportado. Por favor usa una imagen (jpg, jpeg, png, etc.)');
    }

    try {
      // Crear la petición multipart
      final request = http.MultipartRequest('POST', url);

      // Agregar headers
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      // Agregar el archivo
      final fileStream = file.openRead();
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(multipartFile);

      print('🚀 [DealsService] Enviando request a: $url');

      // Enviar la petición
      final streamedResponse = await _client.send(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 60 segundos');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('📥 [DealsService] Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final uploadResponse = ImageUploadResponse.fromJson(json);
        print('✅ [DealsService] Imagen subida exitosamente: ${uploadResponse.secureUrl}');
        return uploadResponse;
      } else {
        throw Exception(_parseError(response, 'Failed to upload image'));
      }
    } catch (e) {
      print('❌ [DealsService] Error uploading image: $e');
      rethrow;
    }
  }

  /// Envía un mensaje de texto al chat
  Future<void> sendTextMessage(
    int quoteId,
    String text,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/chat/messages');

    print('🚀 [DealsService] POST $url');
    print('📤 [DealsService] Sending text message: $text');

    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'dedupKey': null,
          'kind': 'TEXT',
          'text': text,
          'url': null,
          'caption': null,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );

      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('📥 [DealsService] Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [DealsService] Mensaje enviado exitosamente');
      } else {
        throw Exception(_parseError(response, 'Failed to send message'));
      }
    } catch (e) {
      print('❌ [DealsService] Error sending text message: $e');
      rethrow;
    }
  }

  /// Envía un mensaje de imagen al chat
  Future<void> sendImageMessage(
    int quoteId,
    String imageUrl,
    String? caption,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/chat/messages');

    print('🚀 [DealsService] POST $url');
    print('📤 [DealsService] Sending image message: $imageUrl');

    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'dedupKey': null,
          'kind': 'IMAGE',
          'text': null,
          'url': imageUrl,
          'caption': caption,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );

      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('📥 [DealsService] Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [DealsService] Mensaje de imagen enviado exitosamente');
      } else {
        throw Exception(_parseError(response, 'Failed to send image message'));
      }
    } catch (e) {
      print('❌ [DealsService] Error sending image message: $e');
      rethrow;
    }
  }

  /// Marca los mensajes como leídos
  Future<void> markMessagesAsRead(
    int quoteId,
    int lastSeenMessageId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/chat/read');

    print('🚀 [DealsService] PUT $url');
    print('📤 [DealsService] Marking messages as read, lastSeenMessageId: $lastSeenMessageId');

    try {
      final response = await _client.put(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lastSeenMessageId': lastSeenMessageId,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );

      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [DealsService] Mensajes marcados como leídos exitosamente');
      } else {
        throw Exception(_parseError(response, 'Failed to mark messages as read'));
      }
    } catch (e) {
      print('❌ [DealsService] Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Aplica cambios a una cotización
  Future<void> applyQuoteChanges(
    int quoteId,
    QuoteChangeRequestDto changes,
    String accessToken, {
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/changes');

    print('🚀 [DealsService] POST $url');
    print('📤 [DealsService] Applying changes to quote $quoteId');
    print('📤 [DealsService] If-Match: $ifMatch');
    print('📤 [DealsService] Changes: ${jsonEncode(changes.toJson())}');

    try {
      final headers = <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'If-Match': ifMatch,
      };

      if (idempotencyKey != null) {
        headers['Idempotency-Key'] = idempotencyKey;
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(changes.toJson()),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );

      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        print('✅ [DealsService] Cambios aplicados exitosamente');
      } else {
        throw Exception(_parseError(response, 'Failed to apply quote changes'));
      }
    } catch (e) {
      print('❌ [DealsService] Error applying quote changes: $e');
      rethrow;
    }
  }

  /// Obtiene el Content-Type basado en la extensión del archivo
  http.MediaType? _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return http.MediaType('image', 'jpeg');
      case 'png':
        return http.MediaType('image', 'png');
      case 'gif':
        return http.MediaType('image', 'gif');
      case 'webp':
        return http.MediaType('image', 'webp');
      case 'bmp':
        return http.MediaType('image', 'bmp');
      default:
        return null;
    }
  }

  /// Crea una solicitud de aceptación de trato
  Future<void> createAcceptance(
    int quoteId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/acceptances');
    
    print('🚀 [DealsService] POST $url');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_parseError(response, 'Failed to create acceptance'));
      }
    } catch (e) {
      print('❌ [DealsService] Error creating acceptance: $e');
      rethrow;
    }
  }

  /// Confirma una aceptación de trato
  Future<void> confirmAcceptance(
    int quoteId,
    int acceptanceId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/acceptances/$acceptanceId/confirm');
    
    print('🚀 [DealsService] POST $url');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_parseError(response, 'Failed to confirm acceptance'));
      }
    } catch (e) {
      print('❌ [DealsService] Error confirming acceptance: $e');
      rethrow;
    }
  }

  /// Rechaza una aceptación de trato
  Future<void> rejectAcceptance(
    int quoteId,
    int acceptanceId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/acceptances/$acceptanceId/reject');
    
    print('🚀 [DealsService] POST $url');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_parseError(response, 'Failed to reject acceptance'));
      }
    } catch (e) {
      print('❌ [DealsService] Error rejecting acceptance: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles de un cambio propuesto
  Future<ChangeDto> getChange(
    int quoteId,
    int changeId,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/{quoteId}/changes/$changeId');
    
    print('🚀 [DealsService] GET $url');
    
    try {
      final response = await _client.get(
        url,
        headers: {
          'accept': 'application/json',
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
        return ChangeDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception(_parseError(response, 'Failed to get change'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting change: $e');
      rethrow;
    }
  }

  /// Acepta o rechaza un cambio propuesto
  Future<void> decideChange(
    int quoteId,
    int changeId,
    bool accept,
    String accessToken, {
    required String ifMatch,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/quotes/$quoteId/changes/$changeId/decision');
    
    print('🚀 [DealsService] POST $url');
    print('📤 [DealsService] Accept: $accept');
    print('📤 [DealsService] If-Match: $ifMatch');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'If-Match': ifMatch,
        },
        body: jsonEncode({
          'accept': accept,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_parseError(response, 'Failed to decide change'));
      }
    } catch (e) {
      print('❌ [DealsService] Error deciding change: $e');
      rethrow;
    }
  }

  /// Obtiene los conductores de una empresa
  Future<List<DriverDto>> getDrivers(int companyId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/fleet/companies/$companyId/drivers');
    
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
        return jsonList.map((json) => DriverDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_parseError(response, 'Failed to get drivers'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting drivers: $e');
      rethrow;
    }
  }

  /// Obtiene los vehículos de una empresa
  Future<List<VehicleDto>> getVehicles(int companyId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/fleet/companies/$companyId/vehicles');
    
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
        return jsonList.map((json) => VehicleDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_parseError(response, 'Failed to get vehicles'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting vehicles: $e');
      rethrow;
    }
  }

  /// Obtiene la asignación de flota y conductor para una cotización
  Future<AssignmentDto?> getAssignment(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/assignments/by-quote/$quoteId');
    
    print('🚀 [DealsService] GET $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    
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
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AssignmentDto.fromJson(json);
      } else if (response.statusCode == 404) {
        // No hay asignación aún
        return null;
      } else {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to get assignment'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting assignment: $e');
      rethrow;
    }
  }

  /// Asigna o actualiza un conductor y un vehículo a un trato
  Future<void> assignFleetDriver(
    int quoteId,
    int driverId,
    int vehicleId,
    int version,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/$quoteId/assignment');
    
    print('🚀 [DealsService] PUT $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    print('📤 [DealsService] Body: {"driverId": $driverId, "vehicleId": $vehicleId, "version": $version}');
    
    try {
      final response = await _client.put(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'driverId': driverId,
          'vehicleId': vehicleId,
          'version': version,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to assign fleet and driver'));
      }
    } catch (e) {
      print('❌ [DealsService] Error assigning fleet and driver: $e');
      rethrow;
    }
  }

  /// Marca el pago como realizado
  Future<void> paymentMade(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/$quoteId/payment/made');
    
    print('🚀 [DealsService] POST $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to mark payment as made'));
      }
    } catch (e) {
      print('❌ [DealsService] Error marking payment as made: $e');
      rethrow;
    }
  }

  /// Confirma el recibimiento del pago
  Future<void> paymentConfirm(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/$quoteId/payment/confirm');
    
    print('🚀 [DealsService] POST $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to confirm payment'));
      }
    } catch (e) {
      print('❌ [DealsService] Error confirming payment: $e');
      rethrow;
    }
  }

  /// Marca el envío como enviado
  Future<void> shipmentSent(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/$quoteId/shipment/sent');
    
    print('🚀 [DealsService] POST $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to mark shipment as sent'));
      }
    } catch (e) {
      print('❌ [DealsService] Error marking shipment as sent: $e');
      rethrow;
    }
  }

  /// Confirma el recibimiento del envío
  Future<void> shipmentReceived(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/$quoteId/shipment/received');
    
    print('🚀 [DealsService] POST $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    
    try {
      final response = await _client.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El backend no respondió en 10 segundos');
        },
      );
      
      print('📥 [DealsService] Response status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to confirm shipment received'));
      }
    } catch (e) {
      print('❌ [DealsService] Error confirming shipment received: $e');
      rethrow;
    }
  }

  /// Obtiene los items del checklist para una cotización
  Future<List<ChecklistItemDto>> getChecklistItems(int quoteId, String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/deals/checklists/by-quote/$quoteId/items');
    
    print('🚀 [DealsService] GET $url');
    print('🔑 [DealsService] Token recibido: ${accessToken.substring(0, 20)}... (longitud: ${accessToken.length})');
    
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
        return jsonList.map((json) => ChecklistItemDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        print('📥 [DealsService] Response body: ${response.body}');
        throw Exception(_parseError(response, 'Failed to get checklist items'));
      }
    } catch (e) {
      print('❌ [DealsService] Error getting checklist items: $e');
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

