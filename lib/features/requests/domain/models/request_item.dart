/// Modelo de artículo en una solicitud
class RequestItem {
  final String id;
  final String name;
  final double? width; // cm
  final double? height; // cm
  final double? length; // cm
  final double weight; // kg
  final int quantity;
  final bool isFragile;
  final String? imagePath; // Deprecated: usar imagePaths
  final List<String>? imagePaths; // Lista de rutas de imágenes

  const RequestItem({
    required this.id,
    required this.name,
    this.width,
    this.height,
    this.length,
    required this.weight,
    required this.quantity,
    this.isFragile = false,
    this.imagePath,
    this.imagePaths,
  });

  RequestItem copyWith({
    String? id,
    String? name,
    double? width,
    double? height,
    double? length,
    double? weight,
    int? quantity,
    bool? isFragile,
    String? imagePath,
    List<String>? imagePaths,
  }) {
    return RequestItem(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      length: length ?? this.length,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      isFragile: isFragile ?? this.isFragile,
      imagePath: imagePath ?? this.imagePath,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  double get totalWeight => weight * quantity;
  
  // Getter para compatibilidad: retorna la primera imagen si existe
  String? get firstImagePath {
    if (imagePaths != null && imagePaths!.isNotEmpty) {
      return imagePaths!.first;
    }
    return imagePath;
  }
}


