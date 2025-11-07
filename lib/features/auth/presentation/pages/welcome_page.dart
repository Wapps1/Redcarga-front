import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/rc_background.dart';
import '../../../../core/widgets/rc_button.dart';
import '../../../../core/theme.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  const WelcomePage({
    super.key,
    required this.onCreateAccount,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RcBackground(),

          // Contenido realmente centrado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        SvgPicture.asset(
                          'assets/icons/shiny_redcarga_icon.svg',
                          width: 250, height: 250,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bienvenido a',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: RcColors.rcColor6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Red Carga',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: RcColors.rcColor5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botones centrados (ancho controlado)
                        SizedBox(
                          width: 280,
                          child: RcButton(
                            text: 'Crear Cuenta',
                            onPressed: onCreateAccount,
                            enabled: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 280,
                          child: OutlinedButton(
                            onPressed: onLogin,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: RcColors.rcColor7.withOpacity(1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              foregroundColor: RcColors.rcColor6,
                            ),
                            child: const Text('Iniciar Sesión'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}