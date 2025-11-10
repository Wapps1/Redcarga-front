import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CounterofferChatCard extends StatelessWidget {
  final double precio;
  final bool isMyCounteroffer; // true si el usuario actual hizo la contraoferta
  final VoidCallback? onAceptar;
  final VoidCallback? onRechazar;

  const CounterofferChatCard({
    super.key,
    required this.precio,
    this.isMyCounteroffer = false,
    this.onAceptar,
    this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: SweepGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.secondaryContainer,
          ],
          center: Alignment.center,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texto según si es mi contraoferta o de la otra persona
          Text(
            isMyCounteroffer
                ? 'Haz realizado una contraoferta'
                : 'El cliente ha realizado una contraoferta de',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: rcWhite.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
          ),
          if (!isMyCounteroffer) ...[
            const SizedBox(height: 4),
            Text(
              'de',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rcWhite.withOpacity(0.9),
                  ),
            ),
          ],
          const SizedBox(height: 8),
          // Precio
          Text(
            's/${precio.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Ícono de martillo (SVG)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rcWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/deals/assets_temp/contraoferta.svg',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.gavel,
                  size: 35,
                  color: rcWhite,
                ),
              ),
            ),
          ),
          // Botones Aceptar y Rechazar (solo si no es mi contraoferta)
          if (!isMyCounteroffer) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  'Aceptar',
                  rcColor1,
                  colorScheme.primary,
                  onAceptar,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  context,
                  'Rechazar',
                  rcColor1,
                  colorScheme.primary,
                  onRechazar,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
    VoidCallback? onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

