import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/rc_background.dart';
import '../../../../core/widgets/rc_back_button.dart';
import '../../../../core/widgets/rc_button.dart';
import '../../../../core/widgets/rc_text_field.dart';
import '../../../../core/theme.dart';

/// Pantalla de inicio de sesión
class SignInPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onRegisterClick;
  final VoidCallback? onSignIn;

  const SignInPage({
    super.key,
    required this.onBack,
    required this.onRegisterClick,
    this.onSignIn,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _email = '';
  String _password = '';

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        const RcBackground(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // 1) Header fijo (arriba)
                Align(
                  alignment: Alignment.centerLeft,
                  child: RcBackButton(onPressed: widget.onBack),
                ),
                const SizedBox(height: 12),

                // 2) Contenido que ocupa el resto y se centra
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            SvgPicture.asset(
                              'assets/icons/welcome_icon.svg',
                              width: 150, height: 150,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Iniciar Sesión',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: RcColors.rcColor6,
                              ),
                            ),
                            const SizedBox(height: 32),

                            RcTextField(
                              value: _email,
                              onChanged: (v) => setState(() => _email = v),
                              label: 'Correo electrónico',
                              leadingIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            RcTextField(
                              value: _password,
                              onChanged: (v) => setState(() => _password = v),
                              label: 'PIN o Contraseña',
                              leadingIcon: Icons.lock,
                              isPassword: true,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            const SizedBox(height: 24),

                            RcButton(
                              text: 'Iniciar Sesión',
                              onPressed: (_email.isNotEmpty && _password.isNotEmpty)
                                  ? widget.onSignIn
                                  : null,
                              enabled: _email.isNotEmpty && _password.isNotEmpty,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(child: Divider(color: RcColors.rcColor6.withOpacity(0.3))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('o', style: TextStyle(color: RcColors.rcColor6.withOpacity(0.5))),
                                ),
                                Expanded(child: Divider(color: RcColors.rcColor6.withOpacity(0.3))),
                              ],
                            ),
                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: widget.onRegisterClick,
                              child: const Text(
                                '¿No tienes cuenta? Regístrate',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: RcColors.rcColor5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}


