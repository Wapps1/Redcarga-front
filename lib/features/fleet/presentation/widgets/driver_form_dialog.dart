import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_bloc.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_event.dart';
import 'package:red_carga/features/fleet/presentation/blocs/drivers_state.dart';

class DriverFormDialog extends StatefulWidget {
  final int companyId;
  const DriverFormDialog({super.key, required this.companyId});

  @override
  State<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends State<DriverFormDialog> {
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _docCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();

  int _currentStep = 0;
  int? _accountId;
  String? _verificationLink;
  bool _firebaseReady = false;
  bool _identityReady = false;
  bool _waitingCreate = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _licenseCtrl.dispose();
    _docCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _rucCtrl.dispose();
    super.dispose();
  }

  void _nextStep(DriversState state) {
    switch (_currentStep) {
      case 0:
        final email = _emailCtrl.text.trim();
        final username = _usernameCtrl.text.trim();
        final password = _passwordCtrl.text;
        if (email.isEmpty || username.isEmpty || password.length < 6) {
          _showSnack('Completa correo, usuario y contraseña (mínimo 6).');
          return;
        }
        context.read<DriversBloc>().add(
              DriverRegisterAccountRequested(
                email: email,
                username: username,
                password: password,
              ),
            );
        break;
      case 1:
        if (_verificationLink == null || _accountId == null) {
          _showSnack('Aún no se genera el enlace de verificación.');
          return;
        }
        if (!_firebaseReady) {
          context.read<DriversBloc>().add(
                DriverFirebaseLoginRequested(
                  email: _emailCtrl.text.trim(),
                  password: _passwordCtrl.text,
                ),
              );
          return;
        }
        setState(() => _currentStep = 2);
        break;
      case 2:
        final doc = _docCtrl.text.trim();
        final firstName = _firstNameCtrl.text.trim();
        final lastName = _lastNameCtrl.text.trim();
        final phone = _phoneCtrl.text.trim();
        final birthRaw = _birthDateCtrl.text.trim();
        final birthDate = DateTime.tryParse(birthRaw);
        final ruc = _rucCtrl.text.trim();
        if (doc.isEmpty ||
            firstName.isEmpty ||
            lastName.isEmpty ||
            phone.isEmpty ||
            birthRaw.isEmpty ||
            birthDate == null) {
          _showSnack('Completa los datos de identidad (fecha yyyy-MM-dd).');
          return;
        }
        context.read<DriversBloc>().add(
              DriverIdentitySubmitted(
                accountId: _accountId!,
                fullName: '$firstName $lastName',
                docTypeCode: 'DNI',
                docNumber: doc,
                birthDate: birthDate,
                phone: phone,
                ruc: ruc.isEmpty ? '-' : ruc,
              ),
            );
        break;
      case 3:
        final license = _licenseCtrl.text.trim();
        if (license.isEmpty) {
          _showSnack('Ingresa el número de licencia.');
          return;
        }
        setState(() => _waitingCreate = true);
        context.read<DriversBloc>().add(
              CreateDriverRequested(
                companyId: widget.companyId,
                accountId: _accountId!,
                licenseNumber: license,
                active: true,
                plateImageUrl: null,
              ),
            );
        break;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isProcessing(DriversState state) {
    if (_currentStep == 0) return state.registeringAccount;
    if (_currentStep == 1) return state.firebaseSigningIn;
    if (_currentStep == 2) return state.verifyingIdentity;
    if (_currentStep == 3) return state.creating;
    return false;
  }

  Future<void> _openVerificationLink() async {
    if (_verificationLink == null) return;
    final uri = Uri.tryParse(_verificationLink!);
    if (uri == null) {
      _showSnack('Enlace inválido.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      _showSnack('No se pudo abrir el enlace.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const totalSteps = 4;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BlocConsumer<DriversBloc, DriversState>(
        listenWhen: (prev, curr) =>
            prev.pendingAccountId != curr.pendingAccountId ||
            prev.verificationLink != curr.verificationLink ||
            prev.firebaseReady != curr.firebaseReady ||
            prev.identityVerified != curr.identityVerified ||
            prev.creationMessage != curr.creationMessage ||
            prev.creating != curr.creating,
        listener: (context, state) {
          if (state.pendingAccountId != null &&
              state.pendingAccountId != _accountId) {
            setState(() {
              _accountId = state.pendingAccountId;
              _verificationLink = state.verificationLink;
              _currentStep = 1;
            });
            _showSnack('Se envió un correo de verificación.');
          }
          if (state.firebaseReady && !_firebaseReady) {
            setState(() {
              _firebaseReady = true;
              _currentStep = 2;
            });
            _showSnack('Correo verificado, continúa con la identidad.');
          }
          if (state.identityVerified && !_identityReady) {
            setState(() {
              _identityReady = true;
              _currentStep = 3;
            });
            _showSnack('Identidad verificada correctamente.');
          }
          if (state.creationMessage != null) {
            _showSnack(state.creationMessage!);
          }
          if (_waitingCreate && !state.creating) {
            setState(() => _waitingCreate = false);
            if (state.creationMessage == null) Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLastStep = _currentStep == totalSteps - 1;
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: rcColor1,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Registrar Conductor',
                  style: TextStyle(
                    color: rcColor6,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _StepperHeader(current: _currentStep, total: totalSteps),
                const SizedBox(height: 20),
                _buildStepContent(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing(state)
                            ? null
                            : () {
                                context
                                    .read<DriversBloc>()
                                    .add(const DriverCreationFlowReset());
                                Navigator.of(context).pop();
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: rcColor4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: rcColor4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing(state)
                            ? null
                            : () => _nextStep(state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rcColor4,
                          foregroundColor: rcWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isProcessing(state)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(rcWhite),
                                ),
                              )
                            : Text(isLastStep ? 'Crear' : 'Siguiente'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            _FormField(controller: _emailCtrl, label: 'Correo electrónico'),
            const SizedBox(height: 12),
            _FormField(controller: _usernameCtrl, label: 'Nombre de usuario'),
            const SizedBox(height: 12),
            _FormField(
              controller: _passwordCtrl,
              label: 'Contraseña',
              obscure: true,
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Pídele al conductor que verifique su correo usando el enlace generado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: rcColor6),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rcWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: rcColor8.withOpacity(0.4)),
              ),
              child: _verificationLink == null
                  ? const Text(
                      'Enlace pendiente de generación...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: rcColor8),
                    )
                  : TextButton(
                      onPressed: _openVerificationLink,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        alignment: Alignment.center,
                      ),
                      child: const Text(
                        'Link de verificación',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: rcColor4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Luego presiona “Siguiente” para iniciar sesión del conductor en Firebase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: rcColor8),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _FormField(controller: _docCtrl, label: 'Documento (DNI)'),
            const SizedBox(height: 12),
            _FormField(controller: _firstNameCtrl, label: 'Nombres'),
            const SizedBox(height: 12),
            _FormField(controller: _lastNameCtrl, label: 'Apellidos'),
            const SizedBox(height: 12),
            _FormField(controller: _phoneCtrl, label: 'Teléfono'),
            const SizedBox(height: 12),
            _FormField(
              controller: _birthDateCtrl,
              label: 'Fecha de nacimiento (yyyy-MM-dd)',
            ),
            const SizedBox(height: 12),
            _FormField(controller: _rucCtrl, label: 'RUC (opcional)'),
          ],
        );
      case 3:
        return Column(
          children: [
            _FormField(controller: _licenseCtrl, label: 'Número de licencia'),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;

  const _FormField({
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: rcWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  final int current;
  final int total;
  const _StepperHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: rcColor8.withOpacity(0.3),
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex <= current;
        return CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? rcColor4 : rcColor8.withOpacity(0.3),
          child: Text(
            '${stepIndex + 1}',
            style: const TextStyle(color: rcWhite),
          ),
        );
      }),
    );
  }
}