import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:red_carga/core/session/auth_bloc.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/auth/data/repositories/auth_remote_repository_impl.dart';
import 'package:red_carga/features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'package:red_carga/features/auth/data/services/auth_service.dart';
import 'package:red_carga/features/fleet/data/driver_identity_service.dart';
import 'package:red_carga/features/fleet/data/driver_service.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_bloc.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_state.dart';
import 'package:red_carga/features/fleet/presentation/widgets/driver_card.dart';
import 'package:red_carga/features/fleet/presentation/widgets/driver_form_dialog.dart';

class DriversPage extends StatelessWidget {
  final int? companyId;
  const DriversPage({super.key, this.companyId});

  @override
  Widget build(BuildContext context) {
    final sessionCompanyId = context.select<AuthBloc, int?>(
      (bloc) => bloc.state is AuthSignedIn
          ? (bloc.state as AuthSignedIn).session.companyId
          : null,
    );
    final effectiveCompanyId = companyId ?? sessionCompanyId;

    final sessionStore = SessionStore();
    final firebaseAuthRepository = FirebaseAuthRepositoryImpl();
    final authRemoteRepository = AuthRemoteRepositoryImpl(
      authService: AuthService(),
      getFirebaseIdToken: () async {
        final token = await firebaseAuthRepository.getCurrentIdToken();
        if (token == null || token.isEmpty) {
          throw Exception('No se pudo obtener el token de Firebase.');
        }
        return token;
      },
    );

    return BlocProvider(
      create: (_) => DriversBloc(
        driverService: DriverService(sessionStore),
        authRemoteRepository: authRemoteRepository,
        driverIdentityService: DriverIdentityService(
          sessionStore: sessionStore,
          firebaseTokenProvider: firebaseAuthRepository.getCurrentIdToken,
        ),
        firebaseAuthRepository: firebaseAuthRepository,
      ),
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
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && widget.companyId != null) {
      context.read<DriversBloc>().add(DriversRequested(widget.companyId!));
      _loaded = true;
    }
  }

  Future<void> _refresh() async {
    final id = widget.companyId;
    if (id != null) {
      context.read<DriversBloc>().add(DriversRequested(id));
    }
  }

  void _openDialog() {
    final id = widget.companyId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registra tu empresa para agregar choferes.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<DriversBloc>(),
        child: DriverFormDialog(companyId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.companyId == null) {
      return const Scaffold(
        backgroundColor: rcColor1,
        body: SafeArea(child: _CompanyMissingHint()),
      );
    }

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
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
            BlocConsumer<DriversBloc, DriversState>(
              listener: (context, state) {
                if (state.message != null && state.status == DriversStatus.failure) {
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
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _TopBar(
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: _RoundedPanel(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Tus Conductores',
                                        style: TextStyle(
                                          color: rcColor6,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _AddDriverButton(onTap: _openDialog),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildStateContent(state),
                              ],
                            ),
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

  Widget _buildStateContent(DriversState state) {
    switch (state.status) {
      case DriversStatus.initial:
      case DriversStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        );
      case DriversStatus.failure:
        return const _DriversError();
      case DriversStatus.success:
        if (state.drivers.isEmpty) return const _EmptyDrivers();
        return Column(
          children: [
            for (final driver in state.drivers) ...[
              DriverCard(driver: driver),
              const SizedBox(height: 12),
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
          splashRadius: 24,
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: rcWhite,
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Conductores',
          style: TextStyle(
            color: rcWhite,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AddDriverButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddDriverButton({required this.onTap});

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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: rcColor5.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            'Agregar conductor',
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

class _DriversError extends StatelessWidget {
  const _DriversError();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.error_outline, color: rcColor5, size: 48),
        SizedBox(height: 12),
        Text(
          'No se pudo cargar la lista',
          style: TextStyle(color: rcColor6, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          'Desliza hacia abajo para reintentar.',
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.apartment, size: 48, color: rcColor8),
            SizedBox(height: 12),
            Text(
              'Registra tu empresa para administrar conductores.',
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
        Icon(Icons.person_outline, size: 64, color: rcColor8),
        SizedBox(height: 12),
        Text(
          'Aún no tienes conductores',
          style: TextStyle(
            color: rcColor6,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Presiona “Agregar conductor” para crear uno nuevo.',
          style: TextStyle(color: rcColor8),
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
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(32),
      ),
      child: child,
    );
  }
}