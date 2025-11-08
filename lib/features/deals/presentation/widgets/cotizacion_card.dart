import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class CotizacionCard extends StatelessWidget {
  final String empresaNombre;
  final String solicitudNombre;
  final int calificacion; // 1-5 estrellas
  final String precio;
  final VoidCallback? onDetalles;
  final VoidCallback? onChat;

  const CotizacionCard({
    super.key,
    required this.empresaNombre,
    required this.solicitudNombre,
    this.calificacion = 3,
    required this.precio,
    this.onDetalles,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto del header
            Text(
              '$empresaNombre ha realizado una cotización para $solicitudNombre',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Calificación de la empresa
            Row(
              children: [
                Text(
                  'Calificación de la empresa',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: rcColor8,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      index < calificacion ? Icons.star : Icons.star_border,
                      size: 16,
                      color: index < calificacion 
                          ? Colors.orange 
                          : rcColor8,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            
            // Precio propuesto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio propuesto:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetalles,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: rcColor8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Detalles',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rcColor6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onChat,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'Ir al chat',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: rcWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

