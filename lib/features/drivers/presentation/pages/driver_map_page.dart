import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({super.key});

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  String? _selectedRoute;
  bool _isTripActive = false;

  // TODO: Obtener rutas desde el servidor
  final List<Map<String, dynamic>> _availableRoutes = [
    {
      'id': 'R001',
      'name': 'Ruta Lima - Chiclayo',
      'origin': 'La Molina, Lima',
      'destination': 'La Victoria, Chiclayo',
    },
    {
      'id': 'R002',
      'name': 'Ruta Lima - Trujillo',
      'origin': 'Surco, Lima',
      'destination': 'El Porvenir, Trujillo',
    },
    {
      'id': 'R003',
      'name': 'Ruta Lima - Ica',
      'origin': 'Miraflores, Lima',
      'destination': 'Ica, Ica',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    'Mapa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: rcColor6),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Selector de ruta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: rcWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rcColor4.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoute,
                    isExpanded: true,
                    hint: const Text(
                      'Seleccionar ruta',
                      style: TextStyle(
                        color: rcColor8,
                        fontSize: 16,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: rcColor4),
                    items: _availableRoutes.map((route) {
                      return DropdownMenuItem<String>(
                        value: route['id'] as String,
                        child: Text(
                          route['name'] as String,
                          style: const TextStyle(
                            color: rcColor6,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _isTripActive
                        ? null
                        : (String? value) {
                            setState(() {
                              _selectedRoute = value;
                            });
                          },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Información de la ruta seleccionada
            if (_selectedRoute != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildRouteInfo(),
              ),

            const SizedBox(height: 20),

            // Mapa (placeholder)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: rcColor7,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: rcColor4.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Simulación de mapa
                    CustomPaint(
                      painter: _MapPainter(),
                      child: Container(),
                    ),
                    // Mensaje si no hay ruta seleccionada
                    if (_selectedRoute == null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 64,
                              color: rcColor8,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Selecciona una ruta para ver el mapa',
                              style: TextStyle(
                                fontSize: 16,
                                color: rcColor8,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _isTripActive
                  ? _buildFinishTripButton()
                  : _buildStartTripButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    final route = _availableRoutes.firstWhere(
      (r) => r['id'] == _selectedRoute,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rcColor4.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route['name'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: rcColor6,
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildStartTripButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          onTap: _selectedRoute == null
              ? null
              : () {
                  setState(() {
                    _isTripActive = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viaje iniciado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Iniciar Viaje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _selectedRoute == null ? rcColor8 : rcWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishTripButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Finalizar Viaje'),
                content: const Text('¿Estás seguro de que deseas finalizar el viaje?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isTripActive = false;
                        _selectedRoute = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viaje finalizado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Finalizar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Finalizar Viaje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: rcWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter para el mapa estilizado
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fondo del mapa con líneas de calles simuladas
    final streetPaint = Paint()
      ..color = rcColor8.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Líneas horizontales (calles)
    for (double y = size.height * 0.2; y < size.height; y += size.height * 0.25) {
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        streetPaint,
      );
    }

    // Líneas verticales (calles)
    for (double x = size.width * 0.2; x < size.width; x += size.width * 0.3) {
      canvas.drawLine(
        Offset(x, size.height * 0.1),
        Offset(x, size.height * 0.9),
        streetPaint,
      );
    }

    // Ruta principal (línea curva)
    final routePaint = Paint()
      ..color = rcColor5.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    routePath.moveTo(size.width * 0.15, size.height * 0.2);
    routePath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.75,
      size.height * 0.75,
    );
    canvas.drawPath(routePath, routePaint);

    // Puntos de inicio y fin
    final pointPaint = Paint()
      ..color = rcColor5
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 4, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.75), 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

