import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/driver.dart';
import '../../data/driver_service.dart';
import '../blocs/drivers_bloc.dart';
import '../blocs/drivers_event.dart';
import '../blocs/drivers_state.dart';
import '../widgets/driver_card.dart';
import '../widgets/create_driver_modal.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key, required this.companyId});
  final int companyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriversBloc(service: DriverService())..add(LoadDrivers(companyId)),
      child: const _DriversView(),
    );
  }
}

class _DriversView extends StatelessWidget {
  const _DriversView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Conductores', style: tt.titleLarge?.copyWith(color: cs.onPrimary)),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Tus Conductores', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: cs.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => const CreateDriverModal(),
                    );
                  },
                  child: const Text('Agregar Conductor'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<DriversBloc, DriversState>(
                builder: (context, state) {
                  switch (state.status) {
                    case DriversStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case DriversStatus.failure:
                      return Center(child: Text(state.message ?? 'Ocurrió un error'));
                    case DriversStatus.success:
                      if (state.drivers.isEmpty) {
                        return Center(
                          child: Text('Aún no tienes conductores', style: tt.bodyLarge),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.drivers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final Driver d = state.drivers[i];
                          return DriverCard(
                            driver: d,
                            onViewLicense: () {
                              if (d.licenseUrl == null || d.licenseUrl!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sin licencia registrada')),
                                );
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: InteractiveViewer(
                                    child: Image.network(d.licenseUrl!, fit: BoxFit.contain),
                                  ),
                                ),
                              );
                            },
                            onDelete: () {
                              context.read<DriversBloc>().add(DeleteDriver(d.id));
                            },
                          );
                        },
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
