import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:red_carga/core/theme.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_bloc.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_state.dart';
import 'package:red_carga/features/media/data/media_upload_service.dart';

class DriverFormDialog extends StatefulWidget {
  final int companyId;

  const DriverFormDialog({
    super.key,
    required this.companyId,
  });

  @override
  State<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends State<DriverFormDialog> {
  int _currentStep = 0;

  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String _docTypeCode = 'DNI';
  final _docNumberCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController(text: '2000-01-01');
  final _phoneCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();

  final _licenseCtrl = TextEditingController();

  File? _plateImageFile;
  String? _plateImageUrl;
  bool _uploadingImage = false;

  final _formKey = GlobalKey<FormState>();

  int? _accountId;
  String? _verificationLink;
  bool _identityReady = false;
  bool _waitingCreate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DriversBloc>().add(const DriverCreationFlowReset());
    });
  }

  @override
  void dispose() {
    context.read<DriversBloc>().add(const DriverCreationFlowReset());

    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();

    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _docNumberCtrl.dispose();
    _birthDateCtrl.dispose();
    _phoneCtrl.dispose();
    _rucCtrl.dispose();

    _licenseCtrl.dispose();

    super.dispose();
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: rcWhite,
      );

  void _goBack() {
    if (_currentStep == 0) return;
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _goNext() async {
    switch (_currentStep) {
      case 0:
        final email = _emailCtrl.text.trim();
        final username = _usernameCtrl.text.trim();
        final password = _passwordCtrl.text;

        if (email.isEmpty || !email.contains('@')) {
          _showSnack('Ingresa un email válido');
          return;
        }
        if (username.isEmpty) {
          _showSnack('Ingresa un nombre de usuario');
          return;
        }
        if (password.length < 6) {
          _showSnack('La contraseña debe tener al menos 6 caracteres');
          return;
        }

        context.read<DriversBloc>().add(
              DriverRegisterAccountRequested(
                email: email,
                username: username,
                password: password,
              ),
            );
        return;

      case 1:
        if (_verificationLink == null || _accountId == null) {
          _showSnack('Aún no se ha generado el enlace de verificación.');
          return;
        }
        setState(() => _currentStep = 2);
        return;

      case 2:
        if (!(_formKey.currentState?.validate() ?? false)) return;

        final birthDate = DateTime.tryParse(_birthDateCtrl.text.trim());
        if (birthDate == null) {
          _showSnack('Fecha de nacimiento inválida (usa AAAA-MM-DD)');
          return;
        }
        if (_accountId == null) {
          _showSnack('Primero crea y verifica la cuenta del conductor.');
          return;
        }

        final fullName =
            '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();

        context.read<DriversBloc>().add(
              DriverIdentitySubmitted(
                accountId: _accountId!,
                fullName: fullName,
                docTypeCode: _docTypeCode,
                docNumber: _docNumberCtrl.text.trim(),
                birthDate: birthDate,
                phone: _phoneCtrl.text.trim(),
                ruc: _rucCtrl.text.trim(),
              ),
            );
        return;

      case 3:
        _submit();
        return;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _plateImageFile = File(picked.path);
      _uploadingImage = true;
    });

    try {
      final uploader = MediaUploadService(SessionStore());
      final url = await uploader.uploadImage(
        file: _plateImageFile!,
        subjectType: 'DRIVER_PHOTO',
        subjectKey: 'driver_${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() {
        _plateImageUrl = url;
      });
    } catch (e) {
      _showSnack('Error al subir imagen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  void _submit() {
    final license = _licenseCtrl.text.trim();
    if (license.isEmpty) {
      _showSnack('Ingresa el número de licencia');
      return;
    }

    if (_accountId == null) {
      _showSnack('No hay una cuenta de conductor asociada.');
      return;
    }

    context.read<DriversBloc>().add(
          CreateDriverRequested(
            companyId: widget.companyId,
            accountId: _accountId!,
            licenseNumber: license,
            plateImageUrl: _plateImageUrl,
          ),
        );

    setState(() {
      _waitingCreate = true;
    });
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepIam();
      case 1:
        return _buildStepVerifyEmail();
      case 2:
        return _buildStepIdentity();
      case 3:
      default:
        return _buildStepDriverData();
    }
  }

  Widget _buildStepIam() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _emailCtrl,
          decoration: _dec('Email del conductor', icon: Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _usernameCtrl,
          decoration: _dec('Username (para login)', icon: Icons.person),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordCtrl,
          decoration: _dec('Contraseña temporal', icon: Icons.lock_outline),
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        const Text(
          'El proveedor compartirá estas credenciales con el conductor.',
          style: TextStyle(fontSize: 12, color: rcColor8),
        ),
      ],
    );
  }

  Widget _buildStepVerifyEmail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Verifica el correo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Abre el siguiente enlace para confirmar el correo del conductor.',
          style: TextStyle(fontSize: 13, color: rcColor6),
        ),
        const SizedBox(height: 12),
        if (_verificationLink != null)
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  _verificationLink!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: rcColor4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copiar enlace',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _verificationLink!),
                  );
                  _showSnack('Enlace copiado');
                },
                icon: const Icon(Icons.copy, color: rcColor4),
              ),
            ],
          )
        else
          const Text(
            'Generando enlace...',
            style: TextStyle(fontSize: 13, color: rcColor8),
          ),
        const SizedBox(height: 12),
        const Text(
          'Cuando ya se haya verificado el correo, presiona "Siguiente".',
          style: TextStyle(fontSize: 13, color: rcColor8),
        ),
      ],
    );
  }

  Widget _buildStepIdentity() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _firstNameCtrl,
          decoration: _dec('Nombre', icon: Icons.badge_outlined),
          textInputAction: TextInputAction.next,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lastNameCtrl,
          decoration: _dec('Apellido', icon: Icons.badge),
          textInputAction: TextInputAction.next,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa el apellido' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.assignment_ind_outlined, size: 20, color: rcColor8),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _docTypeCode,
                decoration: _dec('Tipo de documento'),
                items: const [
                  DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                  DropdownMenuItem(
                    value: 'CE',
                    child: Text('Carné de Extranjería'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _docTypeCode = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _docNumberCtrl,
          decoration: _dec('N° de documento', icon: Icons.credit_card),
          textInputAction: TextInputAction.next,
          validator: (v) {
            final value = (v ?? '').trim();
            if (value.isEmpty) return 'Ingresa el número de documento';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _birthDateCtrl,
          decoration: _dec(
            'Fecha de nacimiento (AAAA-MM-DD)',
            icon: Icons.calendar_today,
          ),
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          validator: (v) {
            final value = (v ?? '').trim();
            if (value.isEmpty) return 'Ingresa la fecha de nacimiento';
            if (DateTime.tryParse(value) == null) {
              return 'Formato inválido, usa AAAA-MM-DD';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneCtrl,
          decoration: _dec('Teléfono', icon: Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa el teléfono' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _rucCtrl,
          decoration:
              _dec('RUC (empresa o persona natural)', icon: Icons.apartment),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa el RUC' : null,
        ),
      ],
    );
  }

  Widget _buildStepDriverData() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _licenseCtrl,
          decoration:
              _dec('N° de licencia', icon: Icons.credit_card_outlined),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: _uploadingImage
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.image_outlined),
            label: Text(
              _plateImageUrl == null
                  ? 'Subir foto de documento/placa'
                  : 'Cambiar foto',
              style: const TextStyle(color: rcColor5),
            ),
            onPressed: _uploadingImage ? null : _pickAndUploadImage,
          ),
        ),
        if (_plateImageFile != null || _plateImageUrl != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: _plateImageFile != null
                  ? Image.file(
                      _plateImageFile!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      _plateImageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ],
    );
  }

  String get _title {
    switch (_currentStep) {
      case 0:
        return 'Cuenta de acceso (IAM)';
      case 1:
        return 'Verificación de email';
      case 2:
        return 'Datos de identidad';
      case 3:
      default:
        return 'Datos del conductor';
    }
  }

  bool _isProcessing(DriversState state) {
    if (_currentStep == 0) return state.registeringAccount;
    if (_currentStep == 2) return state.verifyingIdentity;
    if (_currentStep == 3) return state.creating;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriversBloc, DriversState>(
      listenWhen: (prev, curr) =>
          prev.pendingAccountId != curr.pendingAccountId ||
          prev.verificationLink != curr.verificationLink ||
          prev.identityVerified != curr.identityVerified ||
          prev.creationMessage != curr.creationMessage ||
          prev.creating != curr.creating ||
          prev.registeringAccount != curr.registeringAccount ||
          prev.verifyingIdentity != curr.verifyingIdentity,
      listener: (context, state) {
        if (!mounted) return;

        if (state.creationMessage != null &&
            !state.registeringAccount &&
            !state.verifyingIdentity &&
            !state.creating) {
          _showSnack(state.creationMessage!);
        }

        if (state.pendingAccountId != null &&
            state.pendingAccountId != _accountId) {
          setState(() {
            _accountId = state.pendingAccountId;
            _verificationLink = state.verificationLink;
            _currentStep = 1;
          });
          _showSnack('Cuenta creada. Verifica el correo del conductor.');
        }

        if (state.identityVerified && !_identityReady) {
          setState(() {
            _identityReady = true;
            _currentStep = 3;
          });
          _showSnack('Identidad verificada correctamente.');
        }

        if (_waitingCreate && !state.creating) {
          if (state.creationMessage == null) {
            _showSnack('Conductor creado correctamente.');
            Navigator.of(context).pop();
          }
          setState(() {
            _waitingCreate = false;
          });
        }
      },
      child: BlocBuilder<DriversBloc, DriversState>(
        builder: (context, state) {
          final processing = _isProcessing(state);

          return AlertDialog(
            backgroundColor: rcColor1,
            title: Text(
              _title,
              style:
                  const TextStyle(color: rcColor6, fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: _buildStepContent(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: rcColor6)),
              ),
              if (_currentStep > 0)
                TextButton(
                  onPressed: processing ? null : _goBack,
                  child: const Text('Atrás', style: TextStyle(color: rcColor6)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: rcColor4,
                  foregroundColor: rcWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: processing ? null : _goNext,
                child: processing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(rcWhite),
                        ),
                      )
                    : Text(_currentStep == 3 ? 'Crear' : 'Siguiente'),
              ),
            ],
          );
        },
      ),
    );
  }
}