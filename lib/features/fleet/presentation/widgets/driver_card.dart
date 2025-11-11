import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class DriverCard extends StatelessWidget {
  final String name;
  final String dni;
  final String phone;

  const DriverCard({
    super.key,
    required this.name,
    required this.dni,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow("Nombre:", name),
          const SizedBox(height: 4),
          _buildRow("DNI:", dni),
          const SizedBox(height: 4),
          _buildRow("Teléfono:", phone),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: rcColor3.withOpacity(0.8),
                foregroundColor: rcWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text("Licencia de conducir"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: rcColor6,
            )),
        Text(value,
            style: const TextStyle(
              color: rcColor6,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
