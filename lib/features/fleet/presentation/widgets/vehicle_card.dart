import 'package:flutter/material.dart';

import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/domain/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: rcColor4.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: rcColor4.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre:',
                  style: TextStyle(
                    color: rcColor6,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Placa:',
                  style: TextStyle(
                    color: rcColor6,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    color: rcColor6,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  vehicle.plate,
                  style: const TextStyle(
                    color: rcColor6,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}