import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/costants/api_constants.dart';
import 'package:red_carga/features/auth/domain/models/identity/person_create_request.dart';

class DriverIdentityService {
  final SessionStore _sessionStore;
  final http.Client _client;
  final Future<String?> Function()? _firebaseTokenProvider;

  DriverIdentityService({
    SessionStore? sessionStore,
    http.Client? client,
    Future<String?> Function()? firebaseTokenProvider,
  })  : _sessionStore = sessionStore ?? SessionStore(),
        _client = client ?? http.Client(),
        _firebaseTokenProvider = firebaseTokenProvider;

  Future<String> _buildAuthorizationHeader() async {
    if (_firebaseTokenProvider != null) {
      final firebaseToken = await _firebaseTokenProvider!.call();
      if (firebaseToken != null && firebaseToken.isNotEmpty) {
        return 'Bearer $firebaseToken';
      }
    }

    final firebaseSession = await _sessionStore.getFirebaseSession();
    if (firebaseSession != null) {
      return 'Bearer ${firebaseSession.idToken}';
    }

    final appSession = await _sessionStore.getAppSession();
    if (appSession == null) {
      throw Exception('No hay sesión activa para crear la identidad.');
    }

    return '${appSession.tokenType.value} ${appSession.accessToken}';
  }

  Future<void> verifyAndCreatePerson(PersonCreateRequest request) async {
    final authorizationHeader = await _buildAuthorizationHeader();

    final uri = Uri.parse(ApiConstants.verifyAndCreatePersonEndpoint);
    final payload = jsonEncode({
      'accountId': request.accountId,
      'fullName': request.fullName,
      'docTypeCode': request.docTypeCode,
      'docNumber': request.docNumber,
      'birthDate': request.birthDate,
      'phone': request.phone,
      'ruc': request.ruc,
    });

    final res = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': authorizationHeader,
      },
      body: payload,
    );

    if (res.statusCode == 200 || res.statusCode == 201) return;

    String message = 'No se pudo registrar la identidad';
    try {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      message = decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          decoded['detail']?.toString() ??
          message;
    } catch (_) {
      if (res.body.isNotEmpty) {
        message = '$message (${res.statusCode}): ${res.body}';
      } else {
        message = '$message (${res.statusCode})';
      }
    }
    throw Exception(message);
  }
}