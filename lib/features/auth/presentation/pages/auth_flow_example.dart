import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'choose_account_type_page.dart';
import 'sign_in_page.dart';
import 'sign_up_client_page.dart';
import 'sign_up_provider_page.dart';

/// Ejemplo de flujo de autenticación completo
/// Este archivo muestra cómo navegar entre las pantallas de autenticación
class AuthFlowExample extends StatefulWidget {
  const AuthFlowExample({super.key});

  @override
  State<AuthFlowExample> createState() => _AuthFlowExampleState();
}

class _AuthFlowExampleState extends State<AuthFlowExample> {
  String _currentScreen = 'welcome';

  void _navigateTo(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 'welcome':
        return WelcomePage(
          onCreateAccount: () => _navigateTo('choose_account'),
          onLogin: () => _navigateTo('sign_in'),
        );
      case 'choose_account':
        return ChooseAccountTypePage(
          onClientSelected: () => _navigateTo('sign_up_client'),
          onProviderSelected: () => _navigateTo('sign_up_provider'),
          onBack: () => _navigateTo('welcome'),
        );
      case 'sign_in':
        return SignInPage(
          onBack: () => _navigateTo('welcome'),
          onRegisterClick: () => _navigateTo('choose_account'),
          onSignInSuccess: () {
            // El AuthWrapper se encargará automáticamente de navegar al home
            // cuando el estado de autenticación cambie a AuthSignedIn
          },
        );
      case 'sign_up_client':
        return SignUpClientPage(
          onBack: () => _navigateTo('choose_account'),
          onComplete: () {
            // TODO: Navegar a la pantalla principal después del registro exitoso
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro de cliente completado'),
                backgroundColor: Colors.green,
              ),
            );
            // _navigateTo('home'); // Cuando tengas la pantalla principal
            _navigateTo('welcome');
          },
        );
      case 'sign_up_provider':
        return SignUpProviderPage(
          onBack: () => _navigateTo('choose_account'),
          onComplete: () {
            // TODO: Navegar a la pantalla principal después del registro exitoso
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro de proveedor completado'),
                backgroundColor: Colors.green,
              ),
            );
            // _navigateTo('home'); // Cuando tengas la pantalla principal
            _navigateTo('welcome');
          },
        );
      default:
        return WelcomePage(
          onCreateAccount: () => _navigateTo('choose_account'),
          onLogin: () => _navigateTo('sign_in'),
        );
    }
  }
}

