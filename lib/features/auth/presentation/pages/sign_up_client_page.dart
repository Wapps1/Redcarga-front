import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/rc_background.dart';
import '../../../../core/widgets/rc_back_button.dart';
import '../../../../core/widgets/rc_button.dart';
import '../../../../core/widgets/rc_text_field.dart';
import '../../../../core/widgets/rc_step_indicator.dart';
import '../../../../core/widgets/rc_dropdown.dart';
import '../../../../core/widgets/rc_date_picker_field.dart';
import '../../../../core/theme.dart';

/// Pantalla de registro de cliente (3 pasos)
class SignUpClientPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onComplete;

  const SignUpClientPage({
    super.key,
    required this.onBack,
    this.onComplete,
  });

  @override
  State<SignUpClientPage> createState() => _SignUpClientPageState();
}

class _SignUpClientPageState extends State<SignUpClientPage> {
  int _currentStep = 1;

  // Paso 1: Credenciales
  String _email = '';
  String _username = '';
  String _password = '';
  String _confirmPassword = '';

  // Paso 2: Verificación Email
  String _verificationLink = '';
  bool _emailVerified = false;

  // Paso 3: Datos Personales
  String _fullName = '';
  String _phone = '';
  String _birthDate = '';
  String _documentType = '';
  String _documentNumber = '';
  String _ruc = '';

  final List<String> _documentTypes = ['DNI', 'Pasaporte', 'Carnet de Extranjería', 'RUC'];

  void _handleBack() {
    if (_currentStep == 1) {
      widget.onBack();
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _handleNext() {
    // Si estamos en el paso 2 y el email no está verificado, primero verificarlo
    if (_currentStep == 2 && !_emailVerified) {
      setState(() {
        _emailVerified = true;
      });
      return;
    }
    
    // Avanzar al siguiente paso o completar
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete?.call();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return _email.isNotEmpty &&
            _username.isNotEmpty &&
            _password.length >= 8 &&
            _password == _confirmPassword &&
            _isValidEmail(_email);
      case 2:
        return true;
      case 3:
        return _fullName.isNotEmpty &&
            _phone.length == 9 &&
            _birthDate.length == 10 &&
            _documentType.isNotEmpty &&
            _documentNumber.isNotEmpty &&
            _ruc.isNotEmpty;
      default:
        return false;
    }
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    // Expresión regular más robusta para validar emails
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RcBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: _currentStep == 3 ? 24 : 48,
              ),
              child: Column(
                children: [
                  // Header
                  SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RcBackButton(onPressed: _handleBack),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Step Indicator
                  RcStepIndicator(
                    currentStep: _currentStep,
                    totalSteps: 3,
                  ),
                  const SizedBox(height: 24),
                  // Contenido scrolleable
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Icono solo en pasos 1 y 2
                          if (_currentStep != 3) ...[
                            SvgPicture.asset(
                              'assets/icons/happy_man_icon.svg',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Contenido del paso
                          _buildStepContent(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Botón
                  RcButton(
                    text: _getButtonText(),
                    onPressed: _canProceed() ? () {
                      if (_canProceed()) {
                        _handleNext();
                      }
                    } : null,
                    enabled: _canProceed(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 1:
        return 'Registrar';
      case 2:
        return _emailVerified ? 'Continuar' : 'Verificar Email';
      case 3:
        return 'Finalizar';
      default:
        return 'Siguiente';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Credentials();
      case 2:
        return _buildStep2EmailVerification();
      case 3:
        return _buildStep3PersonalData();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Credentials() {
    return Column(
      children: [
        const Text(
          'Crea tu cuenta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: RcColors.rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu correo y contraseña',
          style: TextStyle(
            fontSize: 16,
            color: RcColors.rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        RcTextField(
          value: _email,
          onChanged: (value) => setState(() => _email = value),
          label: 'Correo Electrónico',
          leadingIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        RcTextField(
          value: _username,
          onChanged: (value) => setState(() => _username = value),
          label: 'Nombre de Usuario',
          leadingIcon: Icons.person,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        RcTextField(
          value: _password,
          onChanged: (value) => setState(() => _password = value),
          label: 'Contraseña',
          leadingIcon: Icons.lock,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 16),
        RcTextField(
          value: _confirmPassword,
          onChanged: (value) => setState(() => _confirmPassword = value),
          label: 'Confirmar Contraseña',
          leadingIcon: Icons.lock,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
          isError: _confirmPassword.isNotEmpty && _password != _confirmPassword,
          errorMessage: (_confirmPassword.isNotEmpty && _password != _confirmPassword)
              ? 'Las contraseñas no coinciden'
              : null,
        ),
      ],
    );
  }

  Widget _buildStep2EmailVerification() {
    return Column(
      children: [
        const Text(
          'Verifica tu correo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: RcColors.rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Te enviamos un enlace de verificación a tu email. Ábrelo para continuar.',
          style: TextStyle(
            fontSize: 16,
            color: RcColors.rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _email,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: RcColors.rcColor5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (_emailVerified)
          const Text(
            '¡Email verificado exitosamente!',
            style: TextStyle(
              fontSize: 16,
              color: RcColors.black,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildStep3PersonalData() {
    return Column(
      children: [
        const Text(
          'Completa tu perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: RcColors.rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Ingresa tus datos personales',
          style: TextStyle(
            fontSize: 14,
            color: RcColors.rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        RcTextField(
          value: _fullName,
          onChanged: (value) => setState(() => _fullName = value),
          label: 'Nombre Completo',
          leadingIcon: Icons.person,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: _phone,
          onChanged: (value) {
            if (value.length <= 9 && RegExp(r'^\d+$').hasMatch(value)) {
              setState(() => _phone = value);
            }
          },
          label: 'Teléfono',
          leadingIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        RcDatePickerField(
          value: _birthDate,
          onChanged: (value) => setState(() => _birthDate = value),
          label: 'Fecha de Nacimiento',
          leadingIcon: Icons.calendar_today,
        ),
        const SizedBox(height: 18),
        RcDropdown(
          value: _documentType,
          onChanged: (value) => setState(() => _documentType = value),
          label: 'Tipo de Documento',
          options: _documentTypes,
          leadingIcon: Icons.badge,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: _documentNumber,
          onChanged: (value) {
            int maxLength = 20;
            if (_documentType == _documentTypes[0]) {
              maxLength = 8; // DNI
            } else if (_documentType == _documentTypes[3]) {
              maxLength = 11; // RUC
            }
            if (value.length <= maxLength) {
              setState(() => _documentNumber = value);
            }
          },
          label: 'Número de Documento',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: _ruc,
          onChanged: (value) {
            if (value.length <= 11 && RegExp(r'^\d+$').hasMatch(value)) {
              setState(() => _ruc = value);
            }
          },
          label: 'RUC Personal',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

