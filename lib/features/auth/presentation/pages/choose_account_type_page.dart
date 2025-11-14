import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/rc_background.dart';
import '../../../../core/widgets/rc_back_button.dart';
import '../../../../core/theme.dart';

/// Pantalla para elegir el tipo de cuenta
class ChooseAccountTypePage extends StatelessWidget {
  final VoidCallback onClientSelected;
  final VoidCallback onProviderSelected;
  final VoidCallback onBack;

  const ChooseAccountTypePage({
    super.key,
    required this.onClientSelected,
    required this.onProviderSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RcBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 48,
              ),
              child: Column(
                children: [
                  // Header con botón atrás
                  SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RcBackButton(onPressed: onBack),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Título
                  const Text(
                    'Selecciona tu rol',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Card Cliente
                  AccountTypeCard(
                    iconPath: 'assets/icons/truck_icon.svg',
                    title: 'Soy transportista',
                    description: 'Empresa que traslada carga interprovincial.',
                    onTap: onProviderSelected,
                  ),
                  const SizedBox(height: 16),
                  // Card Proveedor
                  AccountTypeCard(
                    iconPath: 'assets/icons/holding_package_icon.svg',
                    title: 'Soy cliente',
                    description: 'Particular que necesita enviar un paquete.',
                    onTap: onClientSelected,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountTypeCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final VoidCallback onTap;

  const AccountTypeCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shadowColor: rcColor5.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      color: rcWhite.withOpacity(0.98),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Icono
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 76,
                    height: 76,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Contenido de texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: rcColor6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: rcColor6.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



