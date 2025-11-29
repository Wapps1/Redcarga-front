import 'package:flutter/material.dart';
import 'request_summary_page.dart';

class ProviderRequestDetailPage extends StatelessWidget {
  final Map<String, dynamic> solicitud;

  const ProviderRequestDetailPage({
    super.key,
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    // Preparar la solicitud con artículos si no vienen
    final solicitudCompleta = Map<String, dynamic>.from(solicitud);
    if (!solicitudCompleta.containsKey('articulos')) {
      solicitudCompleta['articulos'] = [
        {
          'nombre': 'Televisión',
          'cantidad': 8,
          'peso': 30.8,
          'pesoTotal': 246.4,
          'alto': 121.8,
          'ancho': 68.5,
          'largo': 20.0,
          'fragil': true,
        },
      ];
    }

    // Usar RequestSummaryPage con el parámetro solicitud para vista de proveedor
    return RequestSummaryPage(
      solicitud: solicitudCompleta,
    );
  }
}

