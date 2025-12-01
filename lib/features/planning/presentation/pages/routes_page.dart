// lib/features/planning/presentation/pages/routes_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:red_carga/core/theme.dart';
import 'package:red_carga/core/session/auth_bloc.dart';
import 'package:red_carga/core/session/session_store.dart';

import 'package:red_carga/features/planning/data/route_service.dart';
import 'package:red_carga/features/planning/presentation/blocs/routes_bloc.dart';
import 'package:red_carga/features/planning/presentation/blocs/routes_event.dart';
import 'package:red_carga/features/planning/presentation/blocs/routes_state.dart';
import 'package:red_carga/features/planning/presentation/widgets/route_card.dart';
import 'package:red_carga/features/planning/presentation/widgets/route_form_dialog.dart';

class RoutesPage extends StatelessWidget {
  final int? companyId; // opcional: si viene, tiene prioridad
  const RoutesPage({super.key, this.companyId});

  @override
  Widget build(BuildContext context) {
    // companyId desde sesión (AuthBloc) si no vino por parámetro
    final sessionCompanyId = context.select<AuthBloc, int?>((bloc) {
      final s = bloc.state;
      return s is AuthSignedIn ? s.session.companyId : null;
    });

    final effectiveCompanyId = companyId ?? sessionCompanyId;

    return BlocProvider(
      create: (_) => RoutesBloc(service: RouteService(SessionStore())),
      child: _RoutesView(companyId: effectiveCompanyId),
    );
  }
}

class _RoutesView extends StatefulWidget {
  final int? companyId;
  const _RoutesView({required this.companyId});

  @override
  State<_RoutesView> createState() => _RoutesViewState();
}

class _RoutesViewState extends State<_RoutesView> {
  bool _requested = false;
  int? _filterRouteType; // null = todas, 1 = departamento, 2 = provincia

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested && widget.companyId != null) {
      context.read<RoutesBloc>().add(RoutesRequested(widget.companyId!));
      _requested = true;
    }
  }

  Future<void> _refresh() async {
    final id = widget.companyId;
    if (id != null && mounted) {
      context.read<RoutesBloc>().add(RoutesRequested(id));
    }
  }

  void _openCreateDialog() {
    final id = widget.companyId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registra tu empresa para administrar rutas')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => RouteFormDialog(
        onSubmitted: (
          routeTypeId,
          originDeptCode,
          originProvCode,
          destDeptCode,
          destProvCode,
        ) {
          context.read<RoutesBloc>().add(
                CreateRouteRequested(
                  companyId: id,
                  routeTypeId: routeTypeId,
                  originDepartmentCode: originDeptCode,
                  originProvinceCode: originProvCode,
                  destDepartmentCode: destDeptCode,
                  destProvinceCode: destProvCode,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCompany = widget.companyId != null;

    return Scaffold(
      backgroundColor: rcColor1,
      appBar: AppBar(
        backgroundColor: rcColor1,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Rutas',
          style: TextStyle(color: rcColor6, fontWeight: FontWeight.w700),
        ),
        actions: [
          // Filtro por tipo de ruta
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list, color: rcColor4),
            tooltip: 'Filtrar rutas',
            onSelected: (value) {
              setState(() {
                _filterRouteType = value == 0 ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.clear, size: 18),
                    SizedBox(width: 8),
                    Text('Todas'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.map, size: 18),
                    SizedBox(width: 8),
                    Text('Departamento a Departamento'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.location_city, size: 18),
                    SizedBox(width: 8),
                    Text('Provincia a Provincia'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: rcColor4,
        foregroundColor: rcWhite,
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Rutas'),
      ),
      body: !hasCompany
          ? const _CompanyMissingHint()
          : BlocConsumer<RoutesBloc, RoutesState>(
              listener: (context, state) {
                if (state.message != null && state.status == RoutesStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message!), backgroundColor: rcColor5),
                  );
                } else if (state.message != null && state.creating == false && state.status == RoutesStatus.success) {
                  // Éxito al crear
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ruta creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                switch (state.status) {
                  case RoutesStatus.initial:
                  case RoutesStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case RoutesStatus.failure:
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No se pudo cargar la lista')),
                        ],
                      ),
                    );
                  case RoutesStatus.success:
                    final allItems = state.routes;
                    // Filtrar por tipo de ruta si hay un filtro activo
                    final filteredItems = _filterRouteType == null
                        ? allItems
                        : allItems.where((route) => route.routeTypeId == _filterRouteType).toList();
                    
                    if (filteredItems.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const SizedBox(height: 40),
                            _EmptyRoutes(
                              hasFilter: _filterRouteType != null,
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: Column(
                        children: [
                          // Indicador de filtro activo
                          if (_filterRouteType != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: rcColor2.withOpacity(0.2),
                              child: Row(
                                children: [
                                  Icon(
                                    _filterRouteType == 1 ? Icons.map : Icons.location_city,
                                    size: 16,
                                    color: rcColor4,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _filterRouteType == 1
                                        ? 'Filtrando: Departamento a Departamento'
                                        : 'Filtrando: Provincia a Provincia',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: rcColor6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _filterRouteType = null;
                                      });
                                    },
                                    child: const Text(
                                      'Limpiar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: rcColor4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final r = filteredItems[i];
                                // onEdit/onDelete aún no están implementados
                                return RouteCard(
                                  route: r,
                                  onEdit: null,
                                  onDelete: null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                }
              },
            ),
    );
  }
}

class _CompanyMissingHint extends StatelessWidget {
  const _CompanyMissingHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: rcColor8),
            SizedBox(height: 16),
            Text(
              'Registra tu empresa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: rcColor6),
            ),
            SizedBox(height: 8),
            Text(
              'Para administrar rutas, primero debes registrar tu empresa',
              textAlign: TextAlign.center,
              style: TextStyle(color: rcColor8),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutes extends StatelessWidget {
  final bool hasFilter;
  const _EmptyRoutes({this.hasFilter = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, size: 64, color: rcColor8),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'No hay rutas con este filtro' : 'No hay rutas registradas',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: rcColor6),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Intenta cambiar el filtro o crear una nueva ruta'
                : 'Presiona el botón "Agregar Rutas" para crear tu primera ruta',
            textAlign: TextAlign.center,
            style: const TextStyle(color: rcColor8),
          ),
        ],
      ),
    );
  }
}

