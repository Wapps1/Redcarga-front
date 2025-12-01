import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class DriverHomePage extends StatelessWidget {
  final VoidCallback? onNavigateToMap;
  
  const DriverHomePage({super.key, this.onNavigateToMap});

  @override
  Widget build(BuildContext context) {
    // TODO: Obtener rutas asignadas desde el servidor
    final List<Map<String, dynamic>> assignedRoutes = [
      {
        'id': 'R001',
        'name': 'Ruta Lima - Chiclayo',
        'origin': 'La Molina, Lima',
        'destination': 'La Victoria, Chiclayo',
        'status': 'Pendiente',
        'fleet': 'Flota Norte',
      },
      {
        'id': 'R002',
        'name': 'Ruta Lima - Trujillo',
        'origin': 'Surco, Lima',
        'destination': 'El Porvenir, Trujillo',
        'status': 'Pendiente',
        'fleet': 'Flota Norte',
      },
      {
        'id': 'R003',
        'name': 'Ruta Lima - Ica',
        'origin': 'Miraflores, Lima',
        'destination': 'Ica, Ica',
        'status': 'Pendiente',
        'fleet': 'Flota Sur',
      },
    ];

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'CONDUCTORES',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: rcColor6),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Rutas asignadas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: rcColor6,
                ),
              ),
              const SizedBox(height: 16),

              // Cards de rutas asignadas
              if (assignedRoutes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 64,
                          color: rcColor8,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay rutas asignadas',
                          style: TextStyle(
                            fontSize: 16,
                            color: rcColor8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...assignedRoutes.map((route) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRouteCard(context, route),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, Map<String, dynamic> route) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rcColor4.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y ID de ruta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: rcColor6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${route['id']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: rcColor8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 14,
                          color: rcColor4,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          route['fleet'] as String? ?? 'Sin flota',
                          style: const TextStyle(
                            fontSize: 12,
                            color: rcColor8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rcColor2.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  route['status'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: rcColor6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Origen
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: rcColor5, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  route['origin'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: rcColor6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Destino
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: rcColor4, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  route['destination'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: rcColor6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón de inicio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Navegar al mapa usando el callback
                  onNavigateToMap?.call();
                },
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Text(
                    'Iniciar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: rcWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

