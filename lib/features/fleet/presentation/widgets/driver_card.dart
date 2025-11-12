import 'package:flutter/material.dart';
import '../../domain/driver.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({
    super.key,
    required this.driver,
    required this.onViewLicense,
    this.onDelete,
  });

  final Driver driver;
  final VoidCallback onViewLicense;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cs.outline.withOpacity(.25)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Nombre:', driver.name, tt),
          const SizedBox(height: 6),
          _row('DNI:', driver.dni, tt),
          const SizedBox(height: 6),
          _row('Teléfono:', driver.phone, tt),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onViewLicense,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.secondaryContainer,
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, color: cs.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Text('Licencia de conducir', style: tt.labelLarge?.copyWith(color: cs.onSecondaryContainer)),
                    ],
                  ),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline),
                  color: cs.error,
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String left, String right, TextTheme tt) => Row(
        children: [
          Expanded(child: Text(left, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
          Text(right, style: tt.bodyMedium),
        ],
      );
}
