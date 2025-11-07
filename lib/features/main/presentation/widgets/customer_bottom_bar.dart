import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class CustomerBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback? onCreatePressed;

  const CustomerBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.only(bottom: 0),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        //altura
        children: [
          // Barra principal con forma de píldora y corte cóncavo
          Container(
            height: 110,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipPath(
              clipper: _NotchedBarClipper(),
              child: Container(
                padding: const EdgeInsets.only(bottom: 23),
                decoration: BoxDecoration(
                  color: MaterialTheme.lightScheme().surface, // Color superficie
                  borderRadius: BorderRadius.circular(30),
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
                  // Documentos
                  _NavItem(
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description,
                    label: 'Docs',
                    isActive: currentIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                  // Espacio para el botón central
                  const SizedBox(width: 60),
                  // Chat
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Chat',
                    isActive: currentIndex == 2,
                    onTap: () => onChanged(2),
                  ),
                  // Perfil
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Perfil',
                    isActive: currentIndex == 3,
                    onTap: () => onChanged(3),
                  ),
                ],
              ),
            ),
          ),
          ),
          // Botón central "Add" que sobresale
          Positioned(
            top: -30,
            child: GestureDetector(
              onTap: onCreatePressed,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MaterialTheme.lightScheme().primary,
                      MaterialTheme.lightScheme().secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    
                    BoxShadow(
                      color: MaterialTheme.lightScheme().primary.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: MaterialTheme.lightScheme().primary.withOpacity(0.7),
                      offset: const Offset(0, 8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
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

// CustomClipper para crear el corte cóncavo en el centro superior
class _NotchedBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 30.0;
    final notchRadius = 35.0;
    final centerX = size.width / 2;
    final notchDepth = 15.0;

    // Iniciar desde la esquina inferior izquierda
    path.moveTo(radius, size.height);

    // Línea inferior izquierda
    path.lineTo(size.width - radius, size.height);

    // Esquina inferior derecha
    path.arcToPoint(
      Offset(size.width, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Línea derecha
    path.lineTo(size.width, radius);

    // Esquina superior derecha
    path.arcToPoint(
      Offset(size.width - radius, 0),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Línea superior derecha hasta el inicio del notch
    path.lineTo(centerX + notchRadius + 10, 0);

    // Curva cóncava derecha del notch (hacia abajo)
    path.quadraticBezierTo(
      centerX + notchRadius,
      0,
      centerX + notchRadius,
      notchDepth,
    );

    // Arco cóncavo inferior del notch (hacia la izquierda)
    path.arcToPoint(
      Offset(centerX - notchRadius, notchDepth),
      radius: Radius.circular(notchRadius),
      clockwise: false,
      largeArc: false,
    );

    // Curva cóncava izquierda del notch (hacia arriba)
    path.quadraticBezierTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius - 10,
      0,
    );

    // Línea superior izquierda
    path.lineTo(radius, 0);

    // Esquina superior izquierda
    path.arcToPoint(
      Offset(0, radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Línea izquierda
    path.lineTo(0, size.height - radius);

    // Esquina inferior izquierda
    path.arcToPoint(
      Offset(radius, size.height),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
