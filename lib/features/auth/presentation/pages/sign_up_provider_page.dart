import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/rc_background.dart';
import '../../../../core/widgets/rc_back_button.dart';
import '../../../../core/widgets/rc_button.dart';
import '../../../../core/widgets/rc_text_field.dart';
import '../../../../core/widgets/rc_step_indicator.dart';
import '../../../../core/widgets/rc_dropdown.dart';
import '../../../../core/widgets/rc_date_picker_field.dart';
import '../../../../core/theme.dart';
import '../blocs/sign_up_provider/sign_up_provider_bloc.dart';
import '../blocs/sign_up_provider/sign_up_provider_event.dart';
import '../blocs/sign_up_provider/sign_up_provider_state.dart';
import '../../data/di/auth_repositories.dart';

/// Pantalla de registro de proveedor (4 pasos)
class SignUpProviderPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onComplete;

  const SignUpProviderPage({
    super.key,
    required this.onBack,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpProviderBloc(
        authRemoteRepository: AuthRepositories.createAuthRemoteRepository(),
        firebaseAuthRepository:
            AuthRepositories.createFirebaseAuthRepository(),
        identityRemoteRepository:
            AuthRepositories.createIdentityRemoteRepository(),
        providerRemoteRepository:
            AuthRepositories.createProviderRemoteRepository(),
      ),
      child: BlocConsumer<SignUpProviderBloc, SignUpProviderState>(
        listener: (context, state) {
          if (state.isSuccess) {
            onComplete?.call();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                const RcBackground(),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: (state.step == 3 || state.step == 4) ? 24 : 48,
                    ),
                    child: Column(
                      children: [
                        // Header
                        SizedBox(
                          height: 48,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RcBackButton(
                              onPressed: state.step == 1
                                  ? onBack
                                  : () {
                                      context
                                          .read<SignUpProviderBloc>()
                                          .add(const SignUpProviderBack());
                                    },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Step Indicator
                        RcStepIndicator(
                          currentStep: state.step,
                          totalSteps: 4,
                        ),
                        const SizedBox(height: 24),
                        // Contenido scrolleable
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                // Icono solo en pasos 1 y 2
                                if (state.step != 3 && state.step != 4) ...[
                                  const Icon(
                                    Icons.local_shipping,
                                    size: 100,
                                    color: rcColor5,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                // Contenido del paso
                                _buildStepContent(context, state),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        // Botón
                        RcButton(
                          text: _getButtonText(state),
                          onPressed: _canProceed(state)
                              ? () => _handleNext(context, state)
                              : null,
                          enabled: _canProceed(state),
                          isLoading: state.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getButtonText(SignUpProviderState state) {
    switch (state.step) {
      case 1:
        return 'Registrar';
      case 2:
        return state.emailVerified ? 'Continuar' : 'Verificar Email';
      case 3:
        return 'Siguiente';
      case 4:
        return 'Finalizar';
      default:
        return 'Siguiente';
    }
  }

  bool _canProceed(SignUpProviderState state) {
    switch (state.step) {
      case 1:
        return state.email.isNotEmpty &&
            state.username.isNotEmpty &&
            state.password.length >= 8 &&
            state.password == state.confirmPassword &&
            _isValidEmail(state.email) &&
            !state.isLoading;
      case 2:
        return !state.isLoading;
      case 3:
        return state.fullName.isNotEmpty &&
            state.phone.length == 9 &&
            state.birthDate.length == 10 &&
            state.documentType.isNotEmpty &&
            state.documentNumber.isNotEmpty &&
            state.ruc.isNotEmpty &&
            !state.isLoading;
      case 4:
        return state.legalName.isNotEmpty &&
            state.commercialName.isNotEmpty &&
            state.companyRuc.length == 11 &&
            state.companyEmail.isNotEmpty &&
            state.companyPhone.length == 9 &&
            state.address.isNotEmpty &&
            _isValidEmail(state.companyEmail) &&
            !state.isLoading;
      default:
        return false;
    }
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  void _handleNext(BuildContext context, SignUpProviderState state) {
    final bloc = context.read<SignUpProviderBloc>();
    switch (state.step) {
      case 1:
        bloc.add(const SignUpProviderRegisterStart());
        break;
      case 2:
        if (!state.emailVerified) {
          bloc.add(const SignUpProviderEmailVerified());
        }
        break;
      case 3:
        bloc.add(const SignUpProviderVerifyPerson());
        break;
      case 4:
        bloc.add(const SignUpProviderRegisterCompanyAndLogin());
        break;
    }
  }

  Widget _buildStepContent(
    BuildContext context,
    SignUpProviderState state,
  ) {
    switch (state.step) {
      case 1:
        return _buildStep1Credentials(context, state);
      case 2:
        return _buildStep2EmailVerification(context, state);
      case 3:
        return _buildStep3PersonalData(context, state);
      case 4:
        return _buildStep4CompanyData(context, state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Credentials(
    BuildContext context,
    SignUpProviderState state,
  ) {
    final bloc = context.read<SignUpProviderBloc>();
    return Column(
      children: [
        const Text(
          'Crea tu cuenta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu correo y contraseña',
          style: TextStyle(
            fontSize: 16,
            color: rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        RcTextField(
          value: state.email,
          onChanged: (value) =>
              bloc.add(SignUpProviderEmailChanged(value)),
          label: 'Correo Electrónico',
          leadingIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        RcTextField(
          value: state.username,
          onChanged: (value) =>
              bloc.add(SignUpProviderUsernameChanged(value)),
          label: 'Nombre de Usuario',
          leadingIcon: Icons.person,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        RcTextField(
          value: state.password,
          onChanged: (value) =>
              bloc.add(SignUpProviderPasswordChanged(value)),
          label: 'Contraseña',
          leadingIcon: Icons.lock,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 16),
        RcTextField(
          value: state.confirmPassword,
          onChanged: (value) =>
              bloc.add(SignUpProviderConfirmPasswordChanged(value)),
          label: 'Confirmar Contraseña',
          leadingIcon: Icons.lock,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
          isError: state.confirmPassword.isNotEmpty &&
              state.password != state.confirmPassword,
          errorMessage: (state.confirmPassword.isNotEmpty &&
                  state.password != state.confirmPassword)
              ? 'Las contraseñas no coinciden'
              : null,
        ),
      ],
    );
  }

  Widget _buildStep2EmailVerification(
    BuildContext context,
    SignUpProviderState state,
  ) {
    return Column(
      children: [
        const Text(
          'Verifica tu correo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Te enviamos un enlace de verificación a tu email. Ábrelo para continuar.',
          style: TextStyle(
            fontSize: 16,
            color: rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          state.email,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: rcColor5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (state.emailVerified)
          const Text(
            '¡Email verificado exitosamente!',
            style: TextStyle(
              fontSize: 16,
              color: rcColor5,
            ),
            textAlign: TextAlign.center,
          )
        else
          TextButton(
            onPressed: () async {
              final link = state.verificationLink
                  .replaceAll('http://localhost:8080', 'http://10.0.2.2:8080')
                  .replaceAll('https://localhost:8080', 'http://10.0.2.2:8080');
              if (link.isNotEmpty) {
                final uri = Uri.parse(link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              }
            },
            child: const Text(
              'Verificar Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: rcColor5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep3PersonalData(
    BuildContext context,
    SignUpProviderState state,
  ) {
    final bloc = context.read<SignUpProviderBloc>();
    final documentTypes = ['DNI', 'Pasaporte', 'Carnet de Extranjería', 'RUC'];

    return Column(
      children: [
        const Text(
          'Completa tu perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Ingresa tus datos personales',
          style: TextStyle(
            fontSize: 14,
            color: rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        RcTextField(
          value: state.fullName,
          onChanged: (value) =>
              bloc.add(SignUpProviderFullNameChanged(value)),
          label: 'Nombre Completo',
          leadingIcon: Icons.person,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.phone,
          onChanged: (value) {
            if (value.length <= 9 && RegExp(r'^\d+$').hasMatch(value)) {
              bloc.add(SignUpProviderPhoneChanged(value));
            }
          },
          label: 'Teléfono',
          leadingIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        RcDatePickerField(
          value: state.birthDate,
          onChanged: (value) =>
              bloc.add(SignUpProviderBirthDateChanged(value)),
          label: 'Fecha de Nacimiento',
          leadingIcon: Icons.calendar_today,
        ),
        const SizedBox(height: 18),
        RcDropdown(
          value: state.documentType,
          onChanged: (value) =>
              bloc.add(SignUpProviderDocumentTypeChanged(value)),
          label: 'Tipo de Documento',
          options: documentTypes,
          leadingIcon: Icons.badge,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.documentNumber,
          onChanged: (value) {
            int maxLength = 20;
            if (state.documentType == documentTypes[0]) {
              maxLength = 8; // DNI
            } else if (state.documentType == documentTypes[3]) {
              maxLength = 11; // RUC
            }
            if (value.length <= maxLength) {
              bloc.add(SignUpProviderDocumentNumberChanged(value));
            }
          },
          label: 'Número de Documento',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.ruc,
          onChanged: (value) {
            if (value.length <= 11 && RegExp(r'^\d+$').hasMatch(value)) {
              bloc.add(SignUpProviderRucChanged(value));
            }
          },
          label: 'RUC Personal',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildStep4CompanyData(
    BuildContext context,
    SignUpProviderState state,
  ) {
    final bloc = context.read<SignUpProviderBloc>();
    return Column(
      children: [
        const Text(
          'Datos de tu empresa',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Información de tu compañía',
          style: TextStyle(
            fontSize: 14,
            color: rcColor6.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        RcTextField(
          value: state.legalName,
          onChanged: (value) =>
              bloc.add(SignUpProviderLegalNameChanged(value)),
          label: 'Nombre Legal',
          leadingIcon: Icons.business,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.commercialName,
          onChanged: (value) =>
              bloc.add(SignUpProviderCommercialNameChanged(value)),
          label: 'Nombre Comercial',
          leadingIcon: Icons.business,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.companyRuc,
          onChanged: (value) {
            if (value.length <= 11 && RegExp(r'^\d+$').hasMatch(value)) {
              bloc.add(SignUpProviderCompanyRucChanged(value));
            }
          },
          label: 'RUC',
          leadingIcon: Icons.badge,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.companyEmail,
          onChanged: (value) =>
              bloc.add(SignUpProviderCompanyEmailChanged(value)),
          label: 'Email de la Empresa',
          leadingIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.companyPhone,
          onChanged: (value) {
            if (value.length <= 9 && RegExp(r'^\d+$').hasMatch(value)) {
              bloc.add(SignUpProviderCompanyPhoneChanged(value));
            }
          },
          label: 'Teléfono de la Empresa',
          leadingIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        RcTextField(
          value: state.address,
          onChanged: (value) =>
              bloc.add(SignUpProviderAddressChanged(value)),
          label: 'Dirección',
          leadingIcon: Icons.home,
          keyboardType: TextInputType.streetAddress,
          maxLines: 2,
        ),
      ],
    );
  }
}
