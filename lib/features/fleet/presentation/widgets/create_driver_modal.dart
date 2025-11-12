import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/drivers_bloc.dart';
import '../blocs/drivers_event.dart';
import '../blocs/drivers_state.dart';

class CreateDriverModal extends StatefulWidget {
  const CreateDriverModal({super.key});

  @override
  State<CreateDriverModal> createState() => _CreateDriverModalState();
}

class _CreateDriverModalState extends State<CreateDriverModal> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dni = TextEditingController();
  final _phone = TextEditingController();
  File? _licenseFile;

  @override
  void dispose() {
    _name.dispose();
    _dni.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickLicense() async {
    final picker = ImagePicker();
    final XFile? x = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x != null) setState(() => _licenseFile = File(x.path));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final companyId = context.select<DriversBloc, int?>((b) => b.state.companyId) ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: BlocConsumer<DriversBloc, DriversState>(
        listenWhen: (p, c) => p.submitting && !c.submitting,
        listener: (context, state) {
          if (state.message == null) {
            Navigator.pop(context); // cerrado al crear OK
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conductor creado')),
            );
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Crear Conductor', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dni,
                      decoration: const InputDecoration(labelText: 'DNI'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el DNI' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el teléfono' : null,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Licencia de conducir', style: tt.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickLicense,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.tertiary, style: BorderStyle.solid, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                        ),
                        child: _licenseFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: cs.tertiary),
                                  const SizedBox(height: 8),
                                  Text('Tomar foto', style: tt.labelLarge?.copyWith(color: cs.tertiary)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(_licenseFile!, fit: BoxFit.cover, width: double.infinity),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: BorderSide(color: cs.outline),
                            ),
                            onPressed: state.submitting ? null : () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: state.submitting
                                ? null
                                : () {
                                    if (!_form.currentState!.validate()) return;
                                    context.read<DriversBloc>().add(
                                          CreateDriver(
                                            companyId: companyId,
                                            name: _name.text.trim(),
                                            dni: _dni.text.trim(),
                                            phone: _phone.text.trim(),
                                            licenseImage: _licenseFile,
                                          ),
                                        );
                                  },
                            child: state.submitting
                                ? const SizedBox(
                                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Crear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
