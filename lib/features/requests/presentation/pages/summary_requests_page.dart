import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class ResumenSolicitudPage extends StatelessWidget {
  final Map<String, dynamic> solicitud;

  const ResumenSolicitudPage({
    super.key,
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo basados en la foto
    final List<Map<String, dynamic>> articulos = [
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

    final totalArticulos = articulos.fold<int>(
      0,
      (sum, articulo) => sum + (articulo['cantidad'] as int),
    );
    final pesoTotal = articulos.fold<double>(
      0.0,
      (sum, articulo) => sum + (articulo['pesoTotal'] as double),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              rcColor3,
              rcColor5,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              // Contenido principal
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: rcColor1,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información del cliente
                        _buildClienteCard(),
                        const SizedBox(height: 20),
                        // Documentos
                        _buildDocumentosSection(),
                        const SizedBox(height: 20),
                        // Artículos
                        _buildArticulosSection(articulos, totalArticulos, pesoTotal),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: rcWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Información de la Solicitud',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: rcWhite,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: rcWhite),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildClienteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Cliente:', solicitud['nombre'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Día:', solicitud['dia'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Origen:', solicitud['origen'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Destino:', solicitud['destino'] as String),
        ],
      ),
    );
  }

  Widget _buildDocumentosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: rcColor7,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                'DNI del Cliente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, color: rcColor4),
                onPressed: () {
                  // Ver documento
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticulosSection(
    List<Map<String, dynamic>> articulos,
    int totalArticulos,
    double pesoTotal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Artículos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total de Artículos:',
                    style: TextStyle(
                      fontSize: 14,
                      color: rcColor8,
                    ),
                  ),
                  Text(
                    '$totalArticulos',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Peso Total:',
                    style: TextStyle(
                      fontSize: 14,
                      color: rcColor8,
                    ),
                  ),
                  Text(
                    '${pesoTotal.toStringAsFixed(1)}kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Lista de artículos
        ...articulos.map((articulo) => _buildArticuloCard(articulo)),
      ],
    );
  }

  Widget _buildArticuloCard(Map<String, dynamic> articulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen principal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: rcColor7,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, color: rcColor8),
              ),
              const SizedBox(width: 12),
              // Miniaturas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < 3; i++)
                          Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: rcColor7,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, size: 20, color: rcColor8),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Ver fotos
                      },
                      icon: const Icon(Icons.photo_library, size: 16, color: rcColor4),
                      label: const Text(
                        'Ver fotos',
                        style: TextStyle(
                          fontSize: 12,
                          color: rcColor4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nombre y tags
          Row(
            children: [
              Text(
                articulo['nombre'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: rcColor6,
                ),
              ),
              if (articulo['fragil'] as bool) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rcColor3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Frágil',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: rcWhite,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Dimensiones
          _buildInfoRow('Alto:', '${articulo['alto']} cm'),
          const SizedBox(height: 4),
          _buildInfoRow('Ancho:', '${articulo['ancho']} cm'),
          const SizedBox(height: 4),
          _buildInfoRow('largo:', '${articulo['largo']} cm'),
          const SizedBox(height: 8),
          _buildInfoRow('Peso:', '${articulo['peso']} kg'),
          const SizedBox(height: 4),
          _buildInfoRow('Peso Total:', '${articulo['pesoTotal']} kg'),
          const SizedBox(height: 8),
          // Cantidad
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: rcColor8.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'X${articulo['cantidad']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: rcColor6,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: rcColor6,
            ),
          ),
        ),
      ],
    );
  }
}
