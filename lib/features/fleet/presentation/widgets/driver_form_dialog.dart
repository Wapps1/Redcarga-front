import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

typedef DriverSubmit = void Function(
  String firstName,
  String lastName,
  String email,
  String phone,
  String licenseNumber,
);

class DriverFormDialog extends StatefulWidget {
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialLicenseNumber;

  final DriverSubmit onSubmitted;

  const DriverFormDialog({
    super.key,
    this.initialFirstName,
    this.initialLastName,
    this.initialEmail,
    this.initialPhone,
    this.initialLicenseNumber,
    required this.onSubmitted,
  });

  @override
  State<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends State<DriverFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl =
      TextEditingController(text: widget.initialFirstName ?? '');
  late final TextEditingController _lastNameCtrl =
      TextEditingController(text: widget.initialLastName ?? '');
  late final TextEditingController _emailCtrl =
      TextEditingController(text: widget.initialEmail ?? '');
  late final TextEditingController _phoneCtrl =
      TextEditingController(text: widget.initialPhone ?? '');
  late final TextEditingController _licenseCtrl =
      TextEditingController(text: widget.initialLicenseNumber ?? '');

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.onSubmitted(
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _licenseCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: rcWhite,
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialFirstName != null || widget.initialLastName != null;

    return AlertDialog(
      backgroundColor: rcColor1,
      title: Text(
        isEdit ? 'Editar conductor' : 'Nuevo conductor',
        style: const TextStyle(color: rcColor6, fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre
              TextFormField(
                controller: _firstNameCtrl,
                decoration: _dec('Nombre', icon: Icons.badge_outlined),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 12),
              // Apellido
              TextFormField(
                controller: _lastNameCtrl,
                decoration: _dec('Apellido', icon: Icons.badge),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el apellido' : null,
              ),
              const SizedBox(height: 12),
              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: _dec('Email', icon: Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Ingresa el email';
                  if (!value.contains('@')) return 'Email no válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Teléfono
              TextFormField(
                controller: _phoneCtrl,
                decoration: _dec('Teléfono', icon: Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el teléfono' : null,
              ),
              const SizedBox(height: 12),
              // Licencia
              TextFormField(
                controller: _licenseCtrl,
                decoration:
                    _dec('N° de licencia', icon: Icons.credit_card_outlined),
                textInputAction: TextInputAction.done,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el número de licencia'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar', style: TextStyle(color: rcColor6)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: rcColor4,
            foregroundColor: rcWhite,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _submit,
          child: Text(isEdit ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
