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
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocConsumer<VehiclesBloc, VehiclesState>(
        listener: (context, state) {
          if (_submitted && !state.creating && state.message == null) {
            _submitted = false;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
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
          final isLoading = state.creating;

          return Container(
            padding:
                const EdgeInsets.only(left: 28, right: 28, top: 32, bottom: 24),
            decoration: BoxDecoration(
              color: rcColor1,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Crear Flota',
                      style: TextStyle(
                        color: rcColor6,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nombre',
                    style: TextStyle(
                      color: rcColor6,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RoundedField(
                    controller: _nameCtrl,
                    hintText: 'Nombre',
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Ingresa un nombre' : null,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Placa',
                    style: TextStyle(
                      color: rcColor6,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RoundedField(
                    controller: _plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    hintText: 'Placa',
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Ingresa la placa' : null,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: rcColor4, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: rcColor4,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading ? null : _submit,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [rcColor4, rcColor5],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(rcWhite),
                                    ),
                                  )
                                : const Text(
                                    'Crear',
                                    style: TextStyle(
                                      color: rcWhite,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
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
        },
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;

  const _RoundedField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: rcWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: rcColor8.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: rcColor8.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: rcColor4, width: 1.4),
        ),
      ),
    );
  }
}