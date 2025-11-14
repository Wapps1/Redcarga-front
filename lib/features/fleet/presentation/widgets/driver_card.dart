import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/domain/driver.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DriverCard({
    super.key,
    required this.driver,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: rcColor2.withOpacity(0.6),
              child: const Icon(Icons.person, color: rcColor4),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + chip activo
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${driver.firstName} ${driver.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: rcColor6,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (driver.active ? rcColor2 : rcColor7)
                              .withOpacity(0.6),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: driver.active ? rcColor4 : rcColor8,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          driver.active ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 11,
                            color: driver.active ? rcColor4 : rcColor8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Licencia
                  Row(
                    children: [
                      const Icon(Icons.credit_card, size: 16, color: rcColor8),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Licencia: ${driver.licenseNumber}',
                          style: const TextStyle(fontSize: 13, color: rcColor6),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Teléfono
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: rcColor8),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          driver.phone,
                          style: const TextStyle(fontSize: 13, color: rcColor6),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: rcColor8),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          driver.email,
                          style: const TextStyle(fontSize: 13, color: rcColor6),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  tooltip: 'Editar',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: rcColor4),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: rcColor8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
