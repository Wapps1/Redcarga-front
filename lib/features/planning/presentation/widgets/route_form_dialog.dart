import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/requests/data/models/geo_catalog_item.dart';
import 'package:red_carga/features/requests/data/geo_service.dart';

typedef RouteSubmit = void Function(
  int routeTypeId,
  String originDepartmentCode,
  String originProvinceCode,
  String destDepartmentCode,
  String destProvinceCode,
);

class RouteFormDialog extends StatefulWidget {
  final RouteSubmit onSubmitted;

  const RouteFormDialog({
    super.key,
    required this.onSubmitted,
  });

  @override
  State<RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final GeoService _geoService = GeoService();
  
  // Datos geográficos
  List<GeoCatalogItem> _departments = [];
  List<GeoCatalogItem> _originProvinces = [];
  List<GeoCatalogItem> _destProvinces = [];
  
  // Selecciones
  GeoCatalogItem? _selectedOriginDept;
  GeoCatalogItem? _selectedOriginProv;
  GeoCatalogItem? _selectedDestDept;
  GeoCatalogItem? _selectedDestProv;
  
  bool _isLoadingGeo = true;
  int _routeTypeId = 1; // Por defecto DD (Directo-Directo)

  @override
  void initState() {
    super.initState();
    _loadGeoCatalog();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadGeoCatalog() async {
    try {
      setState(() {
        _isLoadingGeo = true;
      });
      
      final departments = await _geoService.getDepartments();
      
      setState(() {
        _departments = departments;
        _isLoadingGeo = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGeo = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar catálogo geográfico: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadOriginProvinces(String departmentCode) async {
    try {
      final provinces = await _geoService.getProvincesByDepartment(departmentCode);
      setState(() {
        _originProvinces = provinces;
        _selectedOriginProv = null; // Reset provincia al cambiar departamento
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar provincias: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDestProvinces(String departmentCode) async {
    try {
      final provinces = await _geoService.getProvincesByDepartment(departmentCode);
      setState(() {
        _destProvinces = provinces;
        _selectedDestProv = null; // Reset provincia al cambiar departamento
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar provincias: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validar departamentos (siempre requeridos)
    if (_selectedOriginDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona departamento de origen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDestDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona departamento de destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Si es tipo 2 (Prov + Prov), validar provincias
    if (_routeTypeId == 2) {
      if (_selectedOriginProv == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona provincia de origen'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDestProv == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona provincia de destino'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Enviar datos: si es tipo 1, enviar códigos vacíos para provincias
    widget.onSubmitted(
      _routeTypeId,
      _selectedOriginDept!.code,
      _routeTypeId == 2 ? (_selectedOriginProv?.code ?? '') : '',
      _selectedDestDept!.code,
      _routeTypeId == 2 ? (_selectedDestProv?.code ?? '') : '',
    );
    Navigator.of(context).pop();
  }

  InputDecoration _dec(String label, {IconData? icon, Color? iconColor}) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: rcColor8,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: icon != null 
            ? Icon(icon, color: iconColor ?? rcColor4, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor8.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor8.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rcColor4, width: 2),
        ),
        filled: true,
        fillColor: rcWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  Widget _buildDepartmentDropdown(bool isOrigin) {
    return DropdownButtonFormField<GeoCatalogItem>(
      value: isOrigin ? _selectedOriginDept : _selectedDestDept,
      decoration: _dec('Departamento', icon: Icons.map_outlined, iconColor: rcColor4),
      style: const TextStyle(
        color: rcColor6,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      isExpanded: true, // Esto evita el overflow
      items: _departments.map((dept) {
        return DropdownMenuItem<GeoCatalogItem>(
          value: dept,
          child: Text(
            dept.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isLoadingGeo
          ? null
          : (GeoCatalogItem? value) {
              setState(() {
                if (isOrigin) {
                  _selectedOriginDept = value;
                  _selectedOriginProv = null;
                  _originProvinces = [];
                } else {
                  _selectedDestDept = value;
                  _selectedDestProv = null;
                  _destProvinces = [];
                }
              });
              if (value != null) {
                if (isOrigin) {
                  _loadOriginProvinces(value.code);
                } else {
                  _loadDestProvinces(value.code);
                }
              }
            },
      validator: (value) => value == null ? 'Selecciona un departamento' : null,
    );
  }

  Widget _buildProvinceDropdown(bool isOrigin) {
    final provinces = isOrigin ? _originProvinces : _destProvinces;
    final selectedProv = isOrigin ? _selectedOriginProv : _selectedDestProv;
    final selectedDept = isOrigin ? _selectedOriginDept : _selectedDestDept;

    return DropdownButtonFormField<GeoCatalogItem>(
      value: selectedProv,
      decoration: _dec('Provincia', icon: Icons.location_city_outlined, iconColor: rcColor4),
      style: const TextStyle(
        color: rcColor6,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      isExpanded: true, // Esto evita el overflow
      items: provinces.map((prov) {
        return DropdownMenuItem<GeoCatalogItem>(
          value: prov,
          child: Text(
            prov.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: selectedDept == null || provinces.isEmpty
          ? null
          : (GeoCatalogItem? value) {
              setState(() {
                if (isOrigin) {
                  _selectedOriginProv = value;
                } else {
                  _selectedDestProv = value;
                }
              });
            },
      validator: (value) {
        // Solo validar si es tipo 2 (Prov + Prov)
        if (_routeTypeId == 2 && value == null) {
          return 'Selecciona una provincia';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: rcColor1,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: rcColor4.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.route, color: rcColor4, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Crear Ruta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: rcColor6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Selector de tipo de ruta
            const Text(
              'Tipo de Ruta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: rcColor6,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 1,
                  label: Text('Depto + Depto'),
                ),
                ButtonSegment<int>(
                  value: 2,
                  label: Text('Prov + Prov'),
                ),
              ],
              selected: {_routeTypeId},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _routeTypeId = newSelection.first;
                  // Reset provincias al cambiar tipo
                  _selectedOriginProv = null;
                  _selectedDestProv = null;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Formulario
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Origen
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: rcWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: rcColor4.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: rcColor4, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Origen',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: rcColor6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingGeo)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(color: rcColor4),
                                ),
                              )
                            else ...[
                              _buildDepartmentDropdown(true),
                              // Solo mostrar provincia si es tipo 2 (Prov + Prov)
                              if (_routeTypeId == 2) ...[
                                const SizedBox(height: 16),
                                _buildProvinceDropdown(true),
                              ],
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Destino
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: rcWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: rcColor5.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: rcColor5, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Destino',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: rcColor6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingGeo)
                              const SizedBox.shrink()
                            else ...[
                              _buildDepartmentDropdown(false),
                              // Solo mostrar provincia si es tipo 2 (Prov + Prov)
                              if (_routeTypeId == 2) ...[
                                const SizedBox(height: 16),
                                _buildProvinceDropdown(false),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Toggle Ruta Activa
            Row(
              children: [
                const Icon(Icons.circle, color: rcColor4, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Ruta Activa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: rcColor6,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: true, // Por defecto activa
                  onChanged: (value) {
                    // Se puede agregar lógica aquí si es necesario
                  },
                  activeColor: rcColor4,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: rcColor4, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: rcColor4,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rcColor4,
                      foregroundColor: rcWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Guardar Ruta',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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

