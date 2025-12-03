import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/data/repositories/deals_repository.dart';
import 'package:red_carga/features/deals/data/models/driver_dto.dart';
import 'package:red_carga/features/deals/data/models/vehicle_dto.dart';
import 'package:red_carga/features/deals/data/models/assignment_dto.dart';
import 'dart:ui';

class AssignFleetDriverModal extends StatefulWidget {
  final int companyId;
  final int quoteId;
  final DealsRepository dealsRepository;
  final Function(int driverId, int vehicleId) onAsignar;

  const AssignFleetDriverModal({
    super.key,
    required this.companyId,
    required this.quoteId,
    required this.dealsRepository,
    required this.onAsignar,
  });

  @override
  State<AssignFleetDriverModal> createState() => _AssignFleetDriverModalState();
}

class _AssignFleetDriverModalState extends State<AssignFleetDriverModal> {
  int? _selectedDriverId;
  int? _selectedVehicleId;
  
  List<DriverDto> _drivers = [];
  List<VehicleDto> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final drivers = await widget.dealsRepository.getDrivers(widget.companyId);
      final vehicles = await widget.dealsRepository.getVehicles(widget.companyId);
      
      // Intentar cargar la asignación actual si existe
      AssignmentDto? currentAssignment;
      try {
        currentAssignment = await widget.dealsRepository.getAssignment(widget.quoteId);
      } catch (e) {
        // Si no hay asignación, continuar normalmente
        print('⚠️ No hay asignación actual o error al cargarla: $e');
      }
      
      if (mounted) {
        setState(() {
          _drivers = drivers.where((d) => d.active).toList();
          _vehicles = vehicles.where((v) => v.active).toList();
          
          // Si hay una asignación actual, preseleccionar los valores
          if (currentAssignment != null) {
            _selectedDriverId = currentAssignment.driverId;
            _selectedVehicleId = currentAssignment.vehicleId;
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar datos: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    if (_isLoading) {
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
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos...'),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                        child: DropdownButton<int>(
                          value: _selectedVehicleId,
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
                          items: _vehicles.map((vehicle) {
                            return DropdownMenuItem<int>(
                              value: vehicle.vehicleId,
                              child: Text(
                                '${vehicle.name} - ${vehicle.plate}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: rcColor6,
                                    ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleId = value;
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
                        child: DropdownButton<int>(
                          value: _selectedDriverId,
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
                            return DropdownMenuItem<int>(
                              value: driver.driverId,
                              child: Text(
                                driver.fullName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: rcColor6,
                                    ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDriverId = value;
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
                          if (_selectedDriverId != null && _selectedVehicleId != null) {
                            Navigator.of(context).pop();
                            widget.onAsignar(_selectedDriverId!, _selectedVehicleId!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor selecciona un conductor y un vehículo'),
                                backgroundColor: Colors.orange,
                              ),
                            );
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
                const SizedBox(height: 12),
                // Botón Cancelar
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancelar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
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

