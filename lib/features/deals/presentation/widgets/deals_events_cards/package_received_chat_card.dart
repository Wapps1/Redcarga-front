import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PackageReceivedChatCard extends StatelessWidget {
  final bool isMyReceipt; // true si el usuario actual confirmó la recepción
  final DateTime? timestamp; // Timestamp del mensaje

  const PackageReceivedChatCard({
    super.key,
    this.isMyReceipt = false,
    this.timestamp,
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
          // Texto según si es mi recepción o de la otra persona
          Text(
            isMyReceipt
                ? 'Has confirmado la recepción del paquete'
                : 'Se ha confirmado la recepción del paquete',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Ícono de paquete (SVG)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rcWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/deals/assets_temp/paquete_recibido.svg',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.inventory,
                  size: 35,
                  color: rcWhite,
                ),
              ),
            ),
          ),
          // Mostrar hora de envío
          if (timestamp != null) ...[
            const SizedBox(height: 12),
            Text(
              _formatMessageTime(timestamp!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: rcWhite.withOpacity(0.7),
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      // Si es hoy, mostrar solo la hora
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Si es ayer
      return 'Ayer ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      // Si es otro día, mostrar fecha y hora
      return DateFormat('dd/MM HH:mm').format(timestamp);
    }
  }
}

