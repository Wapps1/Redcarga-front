/// Respuesta del endpoint de subida de imagen
class ImageUploadResponse {
  final String publicId;
  final String secureUrl;

  ImageUploadResponse({
    required this.publicId,
    required this.secureUrl,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      publicId: json['publicId'] as String? ?? '',
      secureUrl: json['secureUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicId': publicId,
      'secureUrl': secureUrl,
    };
  }
}

