import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_bloc.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/vehicles_state.dart';

class VehicleFormDialog extends StatefulWidget {
  final int companyId;
  const VehicleFormDialog({super.key, required this.companyId});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _nameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _submitted = true;
    context.read<VehiclesBloc>().add(
          VehicleCreatedRequested(
            companyId: widget.companyId,
            name: _nameCtrl.text.trim(),
            plate: _plateCtrl.text.trim().toUpperCase(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehiclesBloc, VehiclesState>(
      listenWhen: (p, c) => p.creating != c.creating || p.message != c.message,
      listener: (context, state) {
        if (_submitted && !state.creating && state.message == null) {
          _submitted = false;
          final messenger = ScaffoldMessenger.maybeOf(context);
          Navigator.of(context).pop();
          messenger?.showSnackBar(
            const SnackBar(content: Text('Flota creada correctamente')),
          );
        } else if (state.message != null && !state.creating) {
          _submitted = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: rcColor1,
          title: const Text(
            'Crear Flota',
            style: TextStyle(color: rcColor6, fontWeight: FontWeight.w700),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    filled: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    filled: true,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ingresa la placa' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: state.creating ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: rcColor6)),
            ),
            ElevatedButton(
              onPressed: state.creating ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: rcColor4,
                foregroundColor: rcWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: state.creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(rcWhite),
                      ),
                    )
                  : const Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}