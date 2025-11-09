import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class ViewCotizacionPage extends StatelessWidget {
  final String tabOrigen; // 'todas', 'en trato', 'en marcha'
  final String empresaNombre;
  final String solicitudNombre;
  final String precio;

  const ViewCotizacionPage({
    super.key,
    required this.tabOrigen,
    this.empresaNombre = 'Empresa 1',
    this.solicitudNombre = 'Solicitud 1',
    this.precio = 's/1000',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    final isTodas = tabOrigen == 'todas';

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de regresar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Menú de opciones
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Título
                    Text(
                      'Información de la empresa',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Información de la empresa
                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(context, 'Razón social:', empresaNombre),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'RUC:', '1234567890'),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Correo:', 'empresa1@empresa.com'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Detalles de la solicitud
                    Text(
                      'Detalles de la solicitud',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(context, 'Empresa:', empresaNombre),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Día:', '10/10/2025'),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Origen:', 'La Molina, Lima'),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Destino:', 'La Victoria, Chiclayo'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Cotización
                    Text(
                      'Cotización',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(context, 'Total de Artículos:', '16'),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Peso Total:', '492.8kg'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Precio propuesto:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: rcColor8,
                                  ),
                            ),
                            Text(
                              precio,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Botón de descargar cotización
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // TODO: Descargar cotización
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.download,
                                      color: rcWhite,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cotización',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: rcWhite,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Comentario
                    Text(
                      'Comentario',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      children: [
                        Text(
                          'No hay problema para transportar las cargas seleccionadas porque se cuenta con capacidad de hasta...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: rcColor6,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Botones de acción
                    if (isTodas) ...[
                      // Botón Iniciar Trato
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: Iniciar trato
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Iniciar Trato',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: rcWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Botón Rechazar Trato
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: rcWhite,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: Rechazar trato
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Rechazar Trato',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Botón Ir al chat (para "en trato" o "en marcha")
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: Ir al chat
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Ir al chat',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: rcWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rcColor8.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: rcColor8,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: rcColor6,
                ),
          ),
        ),
      ],
    );
  }
}

