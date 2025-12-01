import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'quotation_page.dart';

class DetallesSolicitudPage extends StatefulWidget {
  final Map<String, dynamic> solicitud;

  const DetallesSolicitudPage({
    super.key,
    required this.solicitud,
  });

  @override
  State<DetallesSolicitudPage> createState() => _DetallesSolicitudPageState();
}

class _DetallesSolicitudPageState extends State<DetallesSolicitudPage> {
  // Datos de ejemplo basados en la foto
  final List<Map<String, dynamic>> _articulos = [
    {
      'nombre': 'Televisión',
      'cantidad': 8,
      'peso': 30.8,
      'pesoTotal': 246.4,
      'alto': 121.8,
      'ancho': 68.5,
      'largo': 20.0,
      'fragil': true,
      'imagenes': ['', '', '', ''], // URLs de imágenes
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal sin encabezado
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
                child: Column(
                  children: [
                    // Título y botón de retroceso
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: rcColor6),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              'Información de la Solicitud',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: rcColor6,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: rcColor6),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    // Contenido
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _buildInformacionSolicitud(),
                      ),
                    ),
                    // Botones de acción
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionSolicitud() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del cliente
        _buildClienteCard(),
        const SizedBox(height: 20),
        // Documentos
        _buildDocumentosSection(),
        const SizedBox(height: 20),
        // Artículos
        _buildArticulosSection(),
      ],
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
          _buildInfoRow('Cliente:', widget.solicitud['nombre'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Día:', widget.solicitud['dia'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Origen:', widget.solicitud['origen'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Destino:', widget.solicitud['destino'] as String),
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

  Widget _buildArticulosSection() {
    final totalArticulos = _articulos.fold<int>(
      0,
      (sum, articulo) => sum + (articulo['cantidad'] as int),
    );
    final pesoTotal = _articulos.fold<double>(
      0.0,
      (sum, articulo) => sum + (articulo['pesoTotal'] as double),
    );

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
        ..._articulos.map((articulo) => _buildArticuloCard(articulo)),
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


  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rcColor1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGradientButton(
            'Realizar Cotización',
            null,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CotizacionPage(
                    solicitud: widget.solicitud,
                    articulos: _articulos,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOutlinedButton(
            'Rechazar Solicitud',
            null,
            () {
              // Rechazar solicitud
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, IconData? icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [rcColor4, rcColor5],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: rcWhite, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: rcWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String label, IconData? icon, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: rcColor4, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: rcWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: rcColor4, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: rcColor4,
            ),
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
