import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/shared/domain/driver.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;
  const DriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rcColor8.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'Nombre', value: driver.fullName),
          const SizedBox(height: 10),
          _Row(label: 'DNI', value: driver.docNumber ?? '-'),
          const SizedBox(height: 10),
          _Row(label: 'Teléfono', value: driver.phone ?? '-'),
          const SizedBox(height: 10),
          _Row(label: 'Licencia', value: driver.licenseNumber ?? '-'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: rcColor8,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: rcColor6,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}