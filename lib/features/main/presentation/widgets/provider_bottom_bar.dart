import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class ProviderBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const ProviderBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.only(bottom: 23),
      decoration: BoxDecoration(
        color: MaterialTheme.lightScheme().surface, // Color crema/off-white
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isActive: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          // Rutas
          _NavItem(
            icon: Icons.route_outlined,
            activeIcon: Icons.route,
            label: 'Rutas',
            isActive: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          // Documentos
          _NavItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Documentos',
            isActive: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          // Chat
          _NavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'Chat',
            isActive: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
          // Perfil
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
            isActive: currentIndex == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

// Widget para cada item de navegación
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive
                ? MaterialTheme.lightScheme().secondary
                : Colors.grey[600], // Gris para inactivo
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? MaterialTheme.lightScheme().secondary
                  : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
