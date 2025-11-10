import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'dart:ui';

class AssignFleetDriverModal extends StatefulWidget {
  final Function(String fleet, String driver) onAsignar;

  const AssignFleetDriverModal({
    super.key,
    required this.onAsignar,
  });

  @override
  State<AssignFleetDriverModal> createState() => _AssignFleetDriverModalState();
}

class _AssignFleetDriverModalState extends State<AssignFleetDriverModal> {
  String? _selectedFleet;
  String? _selectedDriver;

  // Listas de ejemplo (en producción vendrían de una fuente de datos)
  final List<String> _fleets = ['Flota 1', 'Flota 2', 'Flota 3'];
  final List<String> _drivers = ['Juan Pérez', 'María García', 'Carlos López'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: rcColor1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Asignar Flota y Conductor',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: rcColor6,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // Selector de Flota
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccionar Flota',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: rcColor7,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: rcColor8.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFleet,
                          isExpanded: true,
                          hint: Text(
                            'Selecciona una flota',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: rcColor8,
                                ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: rcColor8,
                          ),
                          items: _fleets.map((fleet) {
                            return DropdownMenuItem<String>(
                              value: fleet,
                              child: Text(
                                fleet,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: rcColor6,
                                    ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFleet = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Selector de Conductor
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccionar Conductor',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: rcColor7,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: rcColor8.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDriver,
                          isExpanded: true,
                          hint: Text(
                            'Selecciona un conductor',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: rcColor8,
                                ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: rcColor8,
                          ),
                          items: _drivers.map((driver) {
                            return DropdownMenuItem<String>(
                              value: driver,
                              child: Text(
                                driver,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: rcColor6,
                                    ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDriver = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón Asignar
                SizedBox(
                  width: double.infinity,
                  child: Container(
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
                          if (_selectedFleet != null && _selectedDriver != null) {
                            widget.onAsignar(_selectedFleet!, _selectedDriver!);
                            Navigator.of(context).pop();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Asignar',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

