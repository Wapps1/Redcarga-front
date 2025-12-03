import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/planning/domain/route.dart';

class RouteCard extends StatelessWidget {
  final PlanningRoute route;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RouteCard({
    super.key,
    required this.route,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: rcWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con tipo de ruta y estado activo
            Row(
              children: [
                // Tag de tipo de ruta
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: rcColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    route.routeTypeId == 2 ? 'Provincia a Provincia' : 'Departamento a Departamento',
                    style: TextStyle(
                      fontSize: 11,
                      color: rcColor6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (route.active ? rcColor2 : rcColor7).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: route.active ? rcColor4 : rcColor8,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    route.active ? 'Activa' : 'Inactiva',
                    style: TextStyle(
                      fontSize: 11,
                      color: route.active ? rcColor4 : rcColor8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            
            // Origen
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: rcColor4),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Origen:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: rcColor8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route.originDisplay,
                        style: const TextStyle(fontSize: 14, color: rcColor6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Destino
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: rcColor5),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destino:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: rcColor8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route.destDisplay,
                        style: const TextStyle(fontSize: 14, color: rcColor6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Actions
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      tooltip: 'Editar',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: rcColor4, size: 20),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Eliminar',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: rcColor8, size: 20),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

