import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: rcWhite,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Subscripciones',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: rcWhite,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Menú de opciones
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: rcWhite,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: rcColor1,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Plan Básico Legal
                        _buildPlanCard(
                          context,
                          title: 'Básico Legal',
                          description:
                              'Diseñado para que todo proveedor pueda operar cumpliendo la ley, sin pagar nada.',
                          price: '\$0.00',
                          pricePeriod: '',
                          features: [
                            'Flota: hasta 2 vehículos activos',
                            'Tracking habilitado para todos los tratos formales',
                            'Chat con clientes activo en tratos y formales',
                            'Reputación: se muestran calificaciones y tags, sin estadísticas avanzadas',
                            'Visibilidad: nivel estándar (aparece luego de los planes pagos)',
                            'Análisis básico: histórico de tratos de los últimos 30 días',
                          ],
                          isHighlighted: false,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Plan Profesional Plus
                        _buildPlanCard(
                          context,
                          title: 'Profesional Plus',
                          description:
                              'Para empresas transportistas que buscan visibilidad, control total y costos más bajos.',
                          price: '\$20.00',
                          pricePeriod: 'mensual',
                          features: [
                            'Flota: hasta 20 vehículos activos (expansible con add-ons)',
                            'Cotizaciones ilimitadas',
                            'Tracking avanzado: con historial de ruta, alertas de parada, y notificación automática al cliente',
                            'Reputación destacada: aparece en el top del ranking y puede responder reseñas',
                            'Visibilidad: prioridad en listados y sugerencias',
                            'Analítica avanzada: dashboard con métricas (eficiencia de rutas, clientes frecuentes, ingresos mensuales)',
                            'Exportaciones: reportes de documentos, tratos y pagos en CSV/PDF',
                          ],
                          isHighlighted: true,
                        ),
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

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    required String pricePeriod,
    required List<String> features,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isHighlighted ? rcColor4 : rcWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isHighlighted ? rcWhite : rcColor6,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          // Descripción
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isHighlighted ? rcWhite.withOpacity(0.9) : rcColor8,
                ),
          ),
          const SizedBox(height: 20),
          
          // Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: isHighlighted ? rcWhite : rcColor6,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (pricePeriod.isNotEmpty) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    pricePeriod,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isHighlighted ? rcWhite.withOpacity(0.9) : rcColor8,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          
          // Características
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isHighlighted ? rcWhite : rcColor4,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isHighlighted ? rcWhite : rcColor6,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Botón Acceder
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Procesar suscripción
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isHighlighted ? rcWhite : rcColor4,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Acceder',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isHighlighted ? rcWhite : rcColor4,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
