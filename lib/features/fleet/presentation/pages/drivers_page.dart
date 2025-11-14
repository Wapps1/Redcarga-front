// lib/features/fleet/presentation/pages/drivers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:red_carga/core/theme.dart';
import 'package:red_carga/core/session/auth_bloc.dart';
import 'package:red_carga/core/session/session_store.dart';

import 'package:red_carga/features/fleet/data/driver_service.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_bloc.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_state.dart';
import 'package:red_carga/features/fleet/presentation/widgets/driver_card.dart';
import 'package:red_carga/features/fleet/presentation/widgets/driver_form_dialog.dart';

class DriversPage extends StatelessWidget {
  final int? companyId; // opcional: si viene, tiene prioridad
  const DriversPage({super.key, this.companyId});

  @override
  Widget build(BuildContext context) {
    // companyId desde sesión (AuthBloc) si no vino por parámetro
    final sessionCompanyId = context.select<AuthBloc, int?>((bloc) {
      final s = bloc.state;
      return s is AuthSignedIn ? s.session.companyId : null;
    });

    final effectiveCompanyId = companyId ?? sessionCompanyId;

    return BlocProvider(
      create: (_) => DriversBloc(service: DriverService(SessionStore())),
      child: _DriversView(companyId: effectiveCompanyId),
    );
  }
}

class _DriversView extends StatefulWidget {
  final int? companyId;
  const _DriversView({required this.companyId});

  @override
  State<_DriversView> createState() => _DriversViewState();
}

class _DriversViewState extends State<_DriversView> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested && widget.companyId != null) {
      context.read<DriversBloc>().add(DriversRequested(widget.companyId!));
      _requested = true;
    }
  }

  Future<void> _refresh() async {
    final id = widget.companyId;
    if (id != null && mounted) {
      context.read<DriversBloc>().add(DriversRequested(id));
    }
  }

  void _openCreateDialog() {
    final id = widget.companyId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registra tu empresa para administrar conductores')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => DriverFormDialog(
        onSubmitted: (firstName, lastName, email, phone, licenseNumber) {
          context.read<DriversBloc>().add(
                CreateDriverRequested(
                  companyId: id,
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                  phone: phone,
                  licenseNumber: licenseNumber,
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
          'Conductores',
          style: TextStyle(color: rcColor6, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar conductor',
            icon: const Icon(Icons.person_add_alt_1, color: rcColor4),
            onPressed: _openCreateDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: rcColor4,
        foregroundColor: rcWhite,
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: !hasCompany
          ? const _CompanyMissingHint()
          : BlocConsumer<DriversBloc, DriversState>(
              listener: (context, state) {
                if (state.message != null && state.status == DriversStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message!), backgroundColor: rcColor5),
                  );
                }
              },
              builder: (context, state) {
                switch (state.status) {
                  case DriversStatus.initial:
                  case DriversStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case DriversStatus.failure:
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No se pudo cargar la lista')),
                        ],
                      ),
                    );
                  case DriversStatus.success:
                    final items = state.drivers;
                    if (items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [
                            SizedBox(height: 40),
                            _EmptyDrivers(),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final d = items[i];
                          // onEdit/onDelete aún no están implementados en tu BLoC actual,
                          // así que los dejamos deshabilitados (null).
                          return DriverCard(
                            driver: d,
                            onEdit: null,
                            onDelete: null,
                          );
                        },
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.apartment, size: 40, color: rcColor8),
            SizedBox(height: 12),
            Text(
              'Aún no tienes una empresa registrada.\nRegístrala para administrar tus conductores.',
              textAlign: TextAlign.center,
              style: TextStyle(color: rcColor6),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDrivers extends StatelessWidget {
  const _EmptyDrivers();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.people_outline, size: 64, color: rcColor8),
        SizedBox(height: 12),
        Text('No hay conductores registrados', style: TextStyle(color: rcColor6)),
        SizedBox(height: 4),
        Text('Toca “Agregar” para crear uno nuevo', style: TextStyle(color: rcColor8)),
      ],
    );
  }
}
