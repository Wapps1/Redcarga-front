import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class FleetCard extends StatelessWidget {
  final String name;
  final String plate;

  const FleetCard({
    super.key,
    required this.name,
    required this.plate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rcColor8.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Nombre:', name),
          const SizedBox(height: 8),
          _buildRow('Placa:', plate),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: rcColor6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: rcColor6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
