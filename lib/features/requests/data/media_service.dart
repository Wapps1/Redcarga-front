import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../costants/api_constants.dart';
import '../../../core/session/session_store.dart';
import 'models/image_upload_response.dart';

class MediaService {
  final http.Client _client;
  final SessionStore _sessionStore;

  MediaService({
    http.Client? client,
    SessionStore? sessionStore,
  })  : _client = client ?? http.Client(),
        _sessionStore = sessionStore ?? SessionStore();

  /// Sube una imagen al servidor y retorna la URL segura
  Future<ImageUploadResponse> uploadImage(String imagePath) async {
    final url = Uri.parse(ApiConstants.uploadImageEndpoint);
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('El archivo de imagen no existe: $imagePath');
    }

    // Obtener token de sesión
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

    print('📤 [MediaService] Subiendo imagen: $imagePath');
    print('📤 [MediaService] Tamaño del archivo: ${await file.length()} bytes');

    // Obtener extensión del archivo y determinar tipo MIME
    final fileName = imagePath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final contentType = _getContentType(extension);
    
    print('📤 [MediaService] Extensión del archivo: $extension');
    print('📤 [MediaService] Content-Type: $contentType');

    if (contentType == null) {
      throw Exception('Tipo de archivo no soportado. Por favor usa una imagen (jpg, jpeg, png, etc.)');
    }

    try {
      // Crear la petición multipart
      final request = http.MultipartRequest('POST', url);
      
      // Agregar headers
      request.headers.addAll({
        'Authorization': '${appSession.tokenType.value} $token',
      });

      // Agregar el archivo con el Content-Type correcto
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
      
      print('📤 [MediaService] Archivo preparado: $fileName (${contentType.toString()})');

      print('🚀 [MediaService] Enviando request a: $url');

      // Enviar la petición
      final streamedResponse = await _client.send(request).timeout(
        const Duration(seconds: 60), // Más tiempo para subir imágenes
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 60 segundos');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [MediaService] Response status: ${response.statusCode}');
      print('📥 [MediaService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final uploadResponse = ImageUploadResponse.fromJson(json);
          print('✅ [MediaService] Imagen subida exitosamente: ${uploadResponse.secureUrl}');
          return uploadResponse;
        } catch (e) {
          throw Exception('Error al parsear respuesta: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [MediaService] Error: $e');
      rethrow;
    }
  }

  /// Sube un PDF al servidor y retorna la respuesta con fileId y cdnUrl
  Future<Map<String, dynamic>> uploadPdf(String pdfPath) async {
    final url = Uri.parse(ApiConstants.uploadPdfEndpoint);
    final file = File(pdfPath);

    if (!await file.exists()) {
      throw Exception('El archivo PDF no existe: $pdfPath');
    }

    // Obtener token de sesión
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

    print('📤 [MediaService] Subiendo PDF: $pdfPath');
    print('📤 [MediaService] Tamaño del archivo: ${await file.length()} bytes');

    try {
      // Crear la petición multipart
      final request = http.MultipartRequest('POST', url);
      
      // Agregar headers
      request.headers.addAll({
        'Authorization': '${appSession.tokenType.value} $token',
      });

      // Agregar el archivo PDF
      final fileName = pdfPath.split('/').last;
      final fileStream = file.openRead();
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: http.MediaType('application', 'pdf'),
      );
      request.files.add(multipartFile);
      
      print('📤 [MediaService] Archivo preparado: $fileName');

      print('🚀 [MediaService] Enviando request a: $url');

      // Enviar la petición
      final streamedResponse = await _client.send(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 60 segundos');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [MediaService] Response status: ${response.statusCode}');
      print('📥 [MediaService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          print('✅ [MediaService] PDF subido exitosamente: ${json['cdnUrl']}');
          return json;
        } catch (e) {
          throw Exception('Error al parsear respuesta: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al subir PDF: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [MediaService] Error: $e');
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
}

