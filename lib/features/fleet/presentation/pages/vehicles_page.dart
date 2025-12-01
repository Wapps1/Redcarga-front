import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:red_carga/core/session/auth_bloc.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/data/vehicle_service.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_bloc.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_state.dart';
import 'package:red_carga/features/fleet/presentation/widgets/vehicle_card.dart';
import 'package:red_carga/features/fleet/presentation/widgets/vehicle_form_dialog.dart';

class VehiclesPage extends StatelessWidget {
  final int? companyId;
  const VehiclesPage({super.key, this.companyId});

  @override
  Widget build(BuildContext context) {
    final sessionCompanyId = context.select<AuthBloc, int?>((bloc) {
      final state = bloc.state;
      return state is AuthSignedIn ? state.session.companyId : null;
    });
    final effectiveCompanyId = companyId ?? sessionCompanyId;

    return BlocProvider(
      create: (_) => VehiclesBloc(vehicleService: VehicleService()),
      child: _VehiclesView(companyId: effectiveCompanyId),
    );
  }
}

class _VehiclesView extends StatefulWidget {
  final int? companyId;
  const _VehiclesView({required this.companyId});

  @override
  State<_VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<_VehiclesView> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && widget.companyId != null) {
      context.read<VehiclesBloc>().add(VehiclesRequested(widget.companyId!));
      _loaded = true;
    }
  }

  Future<void> _refresh() async {
    final id = widget.companyId;
    if (id == null) return;
    context.read<VehiclesBloc>().add(VehiclesRequested(id));
  }

  void _openDialog() {
    final id = widget.companyId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registra tu empresa para agregar flotas')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<VehiclesBloc>(),
        child: VehicleFormDialog(companyId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCompany = widget.companyId != null;

    return Scaffold(
      backgroundColor: rcColor1,
      body: !hasCompany
          ? const SafeArea(child: _CompanyMissingHint())
          : SafeArea(
              child: Stack(
                children: [
                  Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [rcColor4, rcColor5],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  BlocConsumer<VehiclesBloc, VehiclesState>(
                    listener: (context, state) {
                      if (state.message != null &&
                          state.status == VehiclesStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message!)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _TopBar(
                                onBack: () => Navigator.of(context).maybePop(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _RoundedPanel(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 10, 20, 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Tus Flotas',
                                            style: TextStyle(
                                              color: rcColor6,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        _AddFleetButton(onTap: _openDialog),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    _buildStateContent(state),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStateContent(VehiclesState state) {
    switch (state.status) {
      case VehiclesStatus.initial:
      case VehiclesStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        );
      case VehiclesStatus.failure:
        return const _VehiclesError();
      case VehiclesStatus.success:
        final items = state.vehicles;
        if (items.isEmpty) {
          return const _EmptyVehicles();
        }
        return Column(
          children: [
            for (final vehicle in items) ...[
              VehicleCard(vehicle: vehicle),
              const SizedBox(height: 16),
            ],
          ],
        );
    }
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: rcWhite),
        ),
        const SizedBox(width: 4),
        const Text(
          'Flotas',
          style: TextStyle(
            color: rcWhite,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, color: rcWhite),
        ),
      ],
    );
  }
}

class _RoundedPanel extends StatelessWidget {
  final Widget child;
  const _RoundedPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(32),
      ),
      child: child,
    );
  }
}

class _AddFleetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFleetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [rcColor4, rcColor5],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: rcColor5.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Agregar Flota',
            style: TextStyle(
              color: rcWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _VehiclesError extends StatelessWidget {
  const _VehiclesError();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.error_outline, color: rcColor5, size: 40),
        SizedBox(height: 12),
        Text(
          'No se pudo cargar la lista',
          style: TextStyle(color: rcColor6, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          'Desliza hacia abajo para reintentar',
          style: TextStyle(color: rcColor8),
        ),
      ],
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
              'Registra tu empresa para administrar tus flotas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: rcColor6),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVehicles extends StatelessWidget {
  const _EmptyVehicles();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.local_shipping_outlined, size: 64, color: rcColor8),
        SizedBox(height: 12),
        Text(
          'Aún no tienes flotas registradas',
          style: TextStyle(
            color: rcColor6,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Toca “Agregar Flota” para crear la primera',
          style: TextStyle(color: rcColor8),
        ),
      ],
    );
  }
}