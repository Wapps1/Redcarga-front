import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:red_carga/core/session/auth_bloc.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/providers/presentation/pages/subscriptions_page.dart';
import 'package:red_carga/features/providers/presentation/pages/reputation_page.dart';
import 'package:red_carga/features/providers/presentation/pages/settings_page.dart';
import 'package:red_carga/features/providers/presentation/pages/reset_password_page.dart';
import 'package:red_carga/features/providers/presentation/pages/help_center_page.dart';
import 'package:red_carga/features/providers/presentation/pages/transport_documentation_page.dart';
import 'package:red_carga/features/providers/presentation/pages/billing_page.dart';

class ProviderProfilePage extends StatelessWidget {
  const ProviderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    // TODO: Obtener datos reales del usuario desde la sesión
    final userName = 'Juan Perez';
    final ruc = '20123456789';
    final email = 'jcontreras@hotmail.com';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Perfil',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: rcWhite,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // TODO: Menú de opciones
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: rcWhite,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: rcColor1,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información del usuario
                        _buildUserInfoSection(context, userName, ruc, email),
                        
                        const SizedBox(height: 32),
                        
                        // Opciones del menú
                        _buildMenuOption(
                          context,
                          'Documentación de Transportista',
                          Icons.description,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TransportDocumentationPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuOption(
                          context,
                          'Subscripciones',
                          Icons.card_membership,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuOption(
                          context,
                          'Facturación (Comprobantes)',
                          Icons.receipt,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BillingPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuOption(
                          context,
                          'Reputación',
                          Icons.star,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ReputationPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuOption(
                          context,
                          'Configuración',
                          Icons.settings,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuOption(
                          context,
                          'Reestablecer Contraseña',
                          Icons.lock_reset,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ResetPasswordPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuOption(
                          context,
                          'Centro de Ayuda',
                          Icons.help_outline,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const HelpCenterPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón cerrar sesión
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(
    BuildContext context,
    String userName,
    String ruc,
    String email,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Foto de perfil
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rcColor7,
              border: Border.all(
                color: rcColor4,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile_placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 50,
                    color: rcColor4,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Nombre
          Text(
            userName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: rcColor6,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          // RUC
          Text(
            ruc,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcColor8,
                ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcColor8,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: rcColor4,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: rcColor6,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: rcColor8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Cerrar Sesión',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthLogout());
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

