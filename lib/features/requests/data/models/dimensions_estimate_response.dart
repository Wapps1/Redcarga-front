import 'dart:convert';

/// Modelo para la respuesta de estimación de dimensiones
class DimensionsEstimateResponse {
  final double widthCm;
  final double lengthCm;
  final double heightCm;

  DimensionsEstimateResponse({
    required this.widthCm,
    required this.lengthCm,
    required this.heightCm,
  });

  factory DimensionsEstimateResponse.fromJson(Map<String, dynamic> json) {
    return DimensionsEstimateResponse(
      widthCm: (json['width_cm'] as num?)?.toDouble() ?? 0.0,
      lengthCm: (json['length_cm'] as num?)?.toDouble() ?? 0.0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width_cm': widthCm,
      'length_cm': lengthCm,
      'height_cm': heightCm,
    };
  }
}

