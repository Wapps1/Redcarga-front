import '../../domain/models/request_item.dart';
import '../models/create_request_dto.dart';

/// Mapea los datos del formulario al DTO del endpoint
class RequestMappers {
  /// Convierte los datos del formulario a CreateRequestDto
  static CreateRequestDto toCreateRequestDto({
    required String name,
    required String originDeptCode,
    required String originDeptName,
    required String originProvCode,
    required String originProvName,
    required String originDist,
    required String destDeptCode,
    required String destDeptName,
    required String destProvCode,
    required String destProvName,
    required String destDist,
    required bool cashOnDelivery,
    required List<RequestItem> items,
    Map<String, String>? imageUrlMap, // Mapa de rutas locales a URLs
  }) {
    return CreateRequestDto(
      origin: LocationDto(
        departmentCode: originDeptCode,
        departmentName: originDeptName,
        provinceCode: originProvCode,
        provinceName: originProvName,
        districtText: originDist,
      ),
      destination: LocationDto(
        departmentCode: destDeptCode,
        departmentName: destDeptName,
        provinceCode: destProvCode,
        provinceName: destProvName,
        districtText: destDist,
      ),
      paymentOnDelivery: cashOnDelivery,
      requestName: name,
      items: items.map((item) => _toItemDto(item, imageUrlMap)).toList(),
    );
  }

  /// Convierte un RequestItem a ItemDto
  static ItemDto _toItemDto(RequestItem item, Map<String, String>? imageUrlMap) {
    // Calcular peso total
    final totalWeightKg = item.totalWeight;
    
    // Convertir imágenes - usar imagePaths si está disponible, sino usar imagePath
    final images = <ImageDto>[];
    final imagePaths = item.imagePaths ?? (item.imagePath != null ? [item.imagePath!] : []);
    
    for (int i = 0; i < imagePaths.length; i++) {
      final imagePath = imagePaths[i];
      String? imageUrl;
      
      // Si es una URL (empieza con http/https), usarla directamente
      if (imagePath.startsWith('http')) {
        imageUrl = imagePath;
      } 
      // Si es una ruta local y tenemos el mapa de URLs, usar la URL subida
      else if (imageUrlMap != null && imageUrlMap.containsKey(imagePath)) {
        imageUrl = imageUrlMap[imagePath];
      }
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        images.add(ImageDto(
          imageUrl: imageUrl,
          imagePosition: i + 1, // Las posiciones empiezan en 1
        ));
      }
    }
    
    return ItemDto(
      itemName: item.name,
      heightCm: item.height ?? 0.0,
      widthCm: item.width ?? 0.0,
      lengthCm: item.length ?? 0.0,
      weightKg: item.weight,
      totalWeightKg: totalWeightKg,
      quantity: item.quantity,
      fragile: item.isFragile,
      notes: null, // Se puede agregar después si es necesario
      images: images,
    );
  }

}

