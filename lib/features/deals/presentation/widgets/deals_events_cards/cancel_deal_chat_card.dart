import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CancelDealChatCard extends StatelessWidget {
  final bool isMyCancellation; // true si el usuario actual canceló el trato

  const CancelDealChatCard({
    super.key,
    this.isMyCancellation = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
          // Texto según si es mi cancelación o de la otra persona
          Text(
            isMyCancellation
                ? 'has cancelado el trato'
                : 'El cliente ha cancelado el trato',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Ícono de X (SVG)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: rcWhite.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: rcWhite.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/deals/assets_temp/trato_cancelado.svg',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.close,
                  size: 50,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

