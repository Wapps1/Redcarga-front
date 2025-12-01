import 'package:flutter/material.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/presentation/pages/drivers_page.dart';
import 'package:red_carga/features/fleet/presentation/pages/drivers_page.dart';
import 'package:red_carga/features/fleet/presentation/pages/vehicles_page.dart';

class HomePage extends StatelessWidget {
  final UserRole role;

  const HomePage({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomer = role == UserRole.customer;

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título del rol
              Text(
                isCustomer ? 'CLIENTES' : 'PROVEEDORES',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
              const SizedBox(height: 8),
              // Header
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

              // Últimos tratos activos (común para ambos)
              _buildLastActiveDeals(),
              const SizedBox(height: 24),

              // Contenido específico por rol
              if (isCustomer) ...[
                _buildCustomerRoutes(context),
              ] else ...[
                _buildProviderActions(context),
                const SizedBox(height: 24),
                _buildProviderRoutes(context),
                const SizedBox(height: 24),
                _buildProviderDrivers(context),
                const SizedBox(height: 24),
                _buildProviderFleets(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastActiveDeals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor2.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rcColor4.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimos tratos activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: rcColor6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDealCard('Empresa 1', 'Solicitud1')),
              const SizedBox(width: 12),
              Expanded(child: _buildDealCard('Empresa 1', 'Solicitud1')),
              const SizedBox(width: 12),
              Expanded(child: _buildDealCard('Empresa 1', 'Solicitud1')),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: const Text(
                'ver más >',
                style: TextStyle(
                  fontSize: 14,
                  color: rcColor5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(String company, String request) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [rcColor4, rcColor5],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Center(
        child: Text(
          '$company $request',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: rcWhite,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCustomerRoutes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rcColor4.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus Rutas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: rcColor6,
            ),
          ),
          const SizedBox(height: 16),
          // Card interno con fondo blanco
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rcColor4.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitud 1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: rcColor6,
                  ),
                ),
                const Text(
                  '#SI235',
                  style: TextStyle(
                    fontSize: 12,
                    color: rcColor8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: _RouteStops(),
                    ),
                    const SizedBox(width: 12),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 120,
                        height: 90,
                        decoration: BoxDecoration(
                          color: rcColor7,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: rcColor8.withOpacity(0.2), width: 1),
                        ),
                        child: Stack(
                          children: const [
                            CustomPaint(painter: _MapPainter()),
                            Positioned(
                              left: 90,
                              top: 67.5,
                              child: Icon(Icons.location_on, color: rcColor5, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'Ver ruta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Administrar\nRutas',
                Icons.route,
                rcColor2.withOpacity(0.4),
                rcColor4,
                onTap: () {
                  // TODO: navegar a Rutas cuando esté lista
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Administrar\nconductores',
                Icons.person,
                rcColor3.withOpacity(0.4),
                rcColor4,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DriversPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Administrar\nFlotas',
                Icons.local_shipping,
                rcColor3.withOpacity(0.4),
                rcColor5,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VehiclesPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderRoutes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Rutas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rcColor4.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.location_on, color: rcColor5, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La Molina, Lima',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: rcColor6,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: rcColor4, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La Victoria, Chiclayo',
                      style: TextStyle(
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
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [rcColor4, rcColor5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: const Center(
            child: Text(
              'Ver ruta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: rcWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderDrivers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Conductores',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        // Card demo (opcional)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rcColor4.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.person, color: rcColor5, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registra y gestiona a tus conductores',
                  style: TextStyle(fontSize: 14, color: rcColor6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón que navega a DriversPage
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriversPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'Ver conductores',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderFleets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Flotas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rcColor4.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_shipping, color: rcColor5, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Administra tus vehículos y documentos',
                  style: TextStyle(fontSize: 14, color: rcColor6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehiclesPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'Ver flotas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteStops extends StatelessWidget {
  const _RouteStops();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: rcColor5, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'La Molina, Lima',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: rcColor4, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'La Victoria, Chiclayo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter para el mapa estilizado
class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = rcColor8.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = size.height * 0.2; y < size.height; y += size.height * 0.25) {
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        streetPaint,
      );
    }

    for (double x = size.width * 0.2; x < size.width; x += size.width * 0.3) {
      canvas.drawLine(
        Offset(x, size.height * 0.1),
        Offset(x, size.height * 0.9),
        streetPaint,
      );
    }

    final routePaint = Paint()
      ..color = rcColor5.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.75,
      );
    canvas.drawPath(routePath, routePaint);

    final pointPaint = Paint()
      ..color = rcColor5
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 3.5, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.75), 3.5, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
