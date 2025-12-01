import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../../../costants/api_constants.dart';
import '../../../core/session/session_store.dart';
import 'models/dimensions_estimate_response.dart';

class DimensionsService {
  final http.Client _client;
  final SessionStore _sessionStore;

  DimensionsService({
    http.Client? client,
    SessionStore? sessionStore,
  })  : _client = client ?? http.Client(),
        _sessionStore = sessionStore ?? SessionStore();

  /// Estima las dimensiones de un objeto a partir de dos fotos (frontal y lateral)
  /// 
  /// [topPhotoPath] - Ruta de la foto frontal (top_photo)
  /// [sidePhotoPath] - Ruta de la foto lateral (side_photo)
  /// [markerSizeMm] - Tamaño del marcador en milímetros (por defecto 100mm)
  Future<DimensionsEstimateResponse> estimateDimensions({
    required String topPhotoPath,
    required String sidePhotoPath,
    double markerSizeMm = 100.0,
  }) async {
    final url = Uri.parse('${ApiConstants.estimateDimensionsEndpoint}?marker_size_mm=$markerSizeMm');

    // Verificar que los archivos existan
    final topFile = File(topPhotoPath);
    final sideFile = File(sidePhotoPath);

    if (!await topFile.exists()) {
      throw Exception('La foto frontal no existe: $topPhotoPath');
    }

    if (!await sideFile.exists()) {
      throw Exception('La foto lateral no existe: $sidePhotoPath');
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

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= appSession.expiresAt) {
      throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
    }

    // Determinar el tipo MIME para las imágenes
    final topExtension = p.extension(topPhotoPath).toLowerCase();
    final sideExtension = p.extension(sidePhotoPath).toLowerCase();

    MediaType? topContentType = _getContentType(topExtension);
    MediaType? sideContentType = _getContentType(sideExtension);

    if (topContentType == null || sideContentType == null) {
      throw Exception('Tipo de archivo no soportado. Solo se permiten imágenes.');
    }

    print('📐 [DimensionsService] Estimando dimensiones...');
    print('📐 [DimensionsService] Foto frontal: $topPhotoPath');
    print('📐 [DimensionsService] Foto lateral: $sidePhotoPath');
    print('📐 [DimensionsService] Tamaño del marcador: ${markerSizeMm}mm');

    try {
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': '${appSession.tokenType.value} $token',
      });

      // Agregar foto frontal (top_photo)
      final topFileStream = topFile.openRead();
      final topFileLength = await topFile.length();
      final topMultipartFile = http.MultipartFile(
        'top_photo',
        topFileStream,
        topFileLength,
        filename: p.basename(topPhotoPath),
        contentType: topContentType,
      );
      request.files.add(topMultipartFile);

      // Agregar foto lateral (side_photo)
      final sideFileStream = sideFile.openRead();
      final sideFileLength = await sideFile.length();
      final sideMultipartFile = http.MultipartFile(
        'side_photo',
        sideFileStream,
        sideFileLength,
        filename: p.basename(sidePhotoPath),
        contentType: sideContentType,
      );
      request.files.add(sideMultipartFile);

      print('🚀 [DimensionsService] Enviando request a: $url');

      final streamedResponse = await _client.send(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 60 segundos');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [DimensionsService] Response status: ${response.statusCode}');
      print('📥 [DimensionsService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final estimateResponse = DimensionsEstimateResponse.fromJson(json);
          print('✅ [DimensionsService] Dimensiones estimadas: ${estimateResponse.widthCm}cm x ${estimateResponse.lengthCm}cm x ${estimateResponse.heightCm}cm');
          return estimateResponse;
        } catch (e) {
          throw Exception('Error al parsear respuesta: $e. Body: ${response.body}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('El endpoint de estimación de dimensiones no está disponible. Por favor verifica que el servicio esté activo.');
      } else if (response.statusCode == 500) {
        // Intentar parsear el mensaje de error del backend
        try {
          final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = errorJson['message'] as String? ?? errorJson['error'] as String? ?? 'Error del servidor';
          throw Exception('Error del servidor: $errorMessage. Verifica que el endpoint /requests/dimensions/estimate esté disponible.');
        } catch (e) {
          throw Exception('Error del servidor (500). El endpoint podría no estar disponible. Verifica la configuración del backend.');
        }
      } else if (response.statusCode == 422) {
        throw Exception('Error al estimar dimensiones: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Error al estimar dimensiones: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [DimensionsService] Error: $e');
      rethrow;
    }
  }

  MediaType? _getContentType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      case '.bmp':
        return MediaType('image', 'bmp');
      default:
        return null;
    }
  }
}

