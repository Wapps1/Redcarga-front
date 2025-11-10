import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/rc_background.dart';
import '../../../../core/widgets/rc_back_button.dart';
import '../../../../core/widgets/rc_button.dart';
import '../../../../core/widgets/rc_text_field.dart';
import '../../../../core/theme.dart';
import '../blocs/sign_in/sign_in_bloc.dart';
import '../blocs/sign_in/sign_in_event.dart';
import '../blocs/sign_in/sign_in_state.dart';
import '../../data/di/auth_repositories.dart';

/// Pantalla de inicio de sesión
class SignInPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRegisterClick;
  final VoidCallback? onSignInSuccess;

  const SignInPage({
    super.key,
    required this.onBack,
    required this.onRegisterClick,
    this.onSignInSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(
        authRemoteRepository: AuthRepositories.createAuthRemoteRepository(),
        firebaseAuthRepository: AuthRepositories.createFirebaseAuthRepository(),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const RcBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: BlocConsumer<SignInBloc, SignInState>(
                  listener: (context, state) {
                    print('📊 [SignInPage] Estado actualizado - isLoading: ${state.isLoading}, isSuccess: ${state.isSuccess}, error: ${state.error}');
                    
                    if (state.isSuccess) {
                      print('✅ [SignInPage] Login exitoso, llamando callback...');
                      // Pequeño delay para asegurar que el estado se procese
                      Future.microtask(() {
                        print('🎯 [SignInPage] Ejecutando onSignInSuccess callback');
                        onSignInSuccess?.call();
                      });
                    }
                    if (state.error != null) {
                      print('❌ [SignInPage] Mostrando error: ${state.error}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error!),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Botón atrás
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RcBackButton(onPressed: onBack),
                          ),
                          const SizedBox(height: 20),
                          // Logo
                          const Icon(
                            Icons.account_circle,
                            size: 120,
                            color: rcColor5,
                          ),
                          const SizedBox(height: 20),
                          // Título
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: rcColor6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Indicador de carga (si está cargando)
                          if (state.isLoading) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Iniciando sesión...',
                              style: TextStyle(
                                fontSize: 14,
                                color: rcColor5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Campo Email
                          RcTextField(
                            value: state.email,
                            onChanged: (value) {
                              context
                                  .read<SignInBloc>()
                                  .add(SignInEmailChanged(value));
                            },
                            label: 'Correo electrónico',
                            leadingIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          // Campo Password
                          RcTextField(
                            value: state.password,
                            onChanged: (value) {
                              context
                                  .read<SignInBloc>()
                                  .add(SignInPasswordChanged(value));
                            },
                            label: 'PIN o Contraseña',
                            leadingIcon: Icons.lock,
                            isPassword: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          const SizedBox(height: 24),
                          // Botón Iniciar Sesión
                          RcButton(
                            text: 'Iniciar Sesión',
                            onPressed: (state.email.isNotEmpty &&
                                    state.password.isNotEmpty &&
                                    !state.isLoading)
                                ? () {
                                    context
                                        .read<SignInBloc>()
                                        .add(const SignInSubmitted());
                                  }
                                : null,
                            enabled: state.email.isNotEmpty &&
                                state.password.isNotEmpty &&
                                !state.isLoading,
                            isLoading: state.isLoading,
                          ),
                          const SizedBox(height: 16),
                          // Divisor "o"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: rcColor6.withOpacity(0.3),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: rcColor6.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: rcColor6.withOpacity(0.3),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Link registro
                          TextButton(
                            onPressed: onRegisterClick,
                            child: const Text(
                              '¿No tienes cuenta? Regístrate',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: rcColor5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
