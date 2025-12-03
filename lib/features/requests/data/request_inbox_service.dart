// lib/features/requests/data/request_inbox_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/core/session/session_store.dart';
import '../domain/models/request_inbox_item.dart';

class RequestInboxService {
  final SessionStore _sessionStore;
  RequestInboxService(this._sessionStore);

  Future<List<RequestInboxItem>> getRequestInbox({required int companyId}) async {
    final session = await _sessionStore.getAppSession();
    if (session == null) throw Exception('No hay sesión');

    final uri = Uri.parse(ApiConstants.requestInbox(companyId));
    
    print('🚀 [RequestInboxService] Obteniendo solicitudes - GET $uri');
    
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    });

    print('📥 [RequestInboxService] Response status: ${res.statusCode}');
    print('📥 [RequestInboxService] Response body: ${res.body}');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        final list = decoded.cast<Map<String, dynamic>>();
        print('📦 [RequestInboxService] Solicitudes recibidas: ${list.length}');
        return list.map((j) => RequestInboxItem.fromJson(j)).toList();
      }
      return [];
    } else if (res.statusCode == 401) {
      throw Exception('No autorizado. Tu sesión puede haber expirado.');
    }
    throw Exception('Error al obtener solicitudes: ${res.statusCode} ${res.body}');
  }
}

