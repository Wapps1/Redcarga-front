import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/request_item.dart';

class RequestLocalStorage {
  static const String _requestsKey = 'saved_requests';
  static const String _requestCounterKey = 'request_counter';

  /// Guarda una solicitud en el almacenamiento local
  static Future<String> saveRequest({
    required String name,
    required String originDept,
    required String originProv,
    required String originDist,
    required String destDept,
    required String destProv,
    required String destDist,
    required String date,
    required bool cashOnDelivery,
    required List<RequestItem> items,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Obtener el contador de solicitudes
    final counter = (prefs.getInt(_requestCounterKey) ?? 0) + 1;
    await prefs.setInt(_requestCounterKey, counter);
    
    // Crear el ID de la solicitud
    final requestId = 'REQ-${DateTime.now().millisecondsSinceEpoch}';
    
    // Crear el objeto de solicitud
    final requestData = {
      'id': requestId,
      'name': name,
      'originDept': originDept,
      'originProv': originProv,
      'originDist': originDist,
      'destDept': destDept,
      'destProv': destProv,
      'destDist': destDist,
      'date': date,
      'cashOnDelivery': cashOnDelivery,
      'items': items.map((item) => {
        'id': item.id,
        'name': item.name,
        'width': item.width,
        'height': item.height,
        'length': item.length,
        'weight': item.weight,
        'quantity': item.quantity,
        'isFragile': item.isFragile,
        'imagePath': item.imagePath,
      }).toList(),
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending', // pending, sent, error
    };
    
    // Obtener las solicitudes existentes
    final existingRequestsJson = prefs.getString(_requestsKey);
    List<Map<String, dynamic>> requests = [];
    
    if (existingRequestsJson != null) {
      requests = List<Map<String, dynamic>>.from(
        json.decode(existingRequestsJson),
      );
    }
    
    // Agregar la nueva solicitud
    requests.add(requestData);
    
    // Guardar todas las solicitudes
    await prefs.setString(_requestsKey, json.encode(requests));
    
    return requestId;
  }

  /// Obtiene todas las solicitudes guardadas
  static Future<List<Map<String, dynamic>>> getAllRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString(_requestsKey);
    
    if (requestsJson == null) {
      return [];
    }
    
    return List<Map<String, dynamic>>.from(
      json.decode(requestsJson),
    );
  }

  /// Obtiene una solicitud por ID
  static Future<Map<String, dynamic>?> getRequestById(String id) async {
    final requests = await getAllRequests();
    try {
      return requests.firstWhere((req) => req['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Elimina una solicitud por ID
  static Future<bool> deleteRequest(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getAllRequests();
    
    requests.removeWhere((req) => req['id'] == id);
    
    return await prefs.setString(_requestsKey, json.encode(requests));
  }

  /// Actualiza el estado de una solicitud
  static Future<bool> updateRequestStatus(
    String id,
    String status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getAllRequests();
    
    final index = requests.indexWhere((req) => req['id'] == id);
    if (index != -1) {
      requests[index]['status'] = status;
      if (status == 'sent') {
        requests[index]['sentAt'] = DateTime.now().toIso8601String();
      }
      return await prefs.setString(_requestsKey, json.encode(requests));
    }
    
    return false;
  }

  /// Limpia todas las solicitudes
  static Future<bool> clearAllRequests() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_requestsKey);
  }

  /// Convierte los items del JSON a objetos RequestItem
  static List<RequestItem> parseItems(List<dynamic> itemsJson) {
    return itemsJson.map((item) {
      return RequestItem(
        id: item['id'] ?? '',
        name: item['name'] ?? '',
        width: item['width']?.toDouble(),
        height: item['height']?.toDouble(),
        length: item['length']?.toDouble(),
        weight: (item['weight'] ?? 0).toDouble(),
        quantity: item['quantity'] ?? 1,
        isFragile: item['isFragile'] ?? false,
        imagePath: item['imagePath'],
      );
    }).toList();
  }
}

