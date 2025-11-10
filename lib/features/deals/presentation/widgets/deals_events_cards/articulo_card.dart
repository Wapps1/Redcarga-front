import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class ArticuloCard extends StatelessWidget {
  final String titulo;
  final bool esFragil;
  final List<String> fotos;
  final double alto; // cm
  final double ancho; // cm
  final double largo; // cm
  final double peso; // kg
  final int cantidad;
  final VoidCallback? onVerFotos;
  final VoidCallback? onEliminar;
  final Function(int)? onCantidadCambiada;

  const ArticuloCard({
    super.key,
    required this.titulo,
    this.esFragil = false,
    required this.fotos,
    required this.alto,
    required this.ancho,
    required this.largo,
    required this.peso,
    required this.cantidad,
    this.onVerFotos,
    this.onEliminar,
    this.onCantidadCambiada,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    final pesoTotal = peso * cantidad;

    return Dismissible(
      key: Key(titulo),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: rcError,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: rcWhite,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        onEliminar?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: rcColor1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rcColor8.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de imágenes
            Column(
              children: [
                // Imagen principal
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: rcColor7,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rcColor8.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: fotos.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            fotos[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                color: rcColor8,
                                size: 40,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.image,
                          color: rcColor8,
                          size: 40,
                        ),
                ),
                const SizedBox(height: 8),
                // Miniaturas
                if (fotos.length > 1)
                  Row(
                    children: fotos.take(3).map((foto) {
                      return Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: rcColor7,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: rcColor8.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                color: rcColor8,
                                size: 16,
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                // Botón ver fotos
                GestureDetector(
                  onTap: onVerFotos,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          color: rcWhite,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ver fotos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: rcWhite,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Información del artículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y etiqueta frágil
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: rcColor6,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (esFragil)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rcError,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Frágil',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: rcWhite,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dimensiones
                  _buildInfoRow(context, 'Alto:', '${alto.toStringAsFixed(1)} cm'),
                  const SizedBox(height: 4),
                  _buildInfoRow(context, 'Ancho:', '${ancho.toStringAsFixed(1)} cm'),
                  const SizedBox(height: 4),
                  _buildInfoRow(context, 'Largo:', '${largo.toStringAsFixed(1)} cm'),
                  const SizedBox(height: 4),
                  _buildInfoRow(context, 'Peso:', '${peso.toStringAsFixed(1)} kg'),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    context,
                    'Peso Total:',
                    '${pesoTotal.toStringAsFixed(1)} kg',
                  ),
                  const SizedBox(height: 12),
                  // Controles de cantidad
                  Row(
                    children: [
                      Text(
                        'Cantidad:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: rcColor8,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: cantidad > 1
                                  ? () {
                                      onCantidadCambiada?.call(cantidad - 1);
                                    }
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                size: 18,
                                color: cantidad > 1 ? rcColor6 : rcColor8,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'X$cantidad',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: rcColor6,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                onCantidadCambiada?.call(cantidad + 1);
                              },
                              icon: Icon(
                                Icons.add,
                                size: 18,
                                color: rcColor6,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: rcColor8,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: rcColor6,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

