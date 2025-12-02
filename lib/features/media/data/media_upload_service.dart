import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/core/session/session_store.dart';

class MediaUploadService {
  final SessionStore _sessionStore;

  MediaUploadService(this._sessionStore);

  Future<String> uploadImage({
    required File file,
    required String subjectType,
    required String subjectKey,
  }) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(
      ApiConstants.uploadImage(
        subjectType: subjectType,
        subjectKey: subjectKey,
      ),
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${session.accessToken}'
      ..headers['Accept'] = 'application/json'
      ..files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return (json['secureUrl'] ?? json['publicId']) as String;
    }

    throw Exception('Error al subir imagen: ${res.statusCode} ${res.body}');
  }
}
