import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMadeChatCard extends StatelessWidget {
  final bool isMyPayment; // true si el usuario actual confirmó el pago
  final String? systemSubtypeCode; // PAYMENT_MADE o PAYMENT_CONFIRMED
  final DateTime? timestamp; // Timestamp del mensaje
  final VoidCallback? onConfirmarRecepcion; // Callback para confirmar recepción del pago

  const PaymentMadeChatCard({
    super.key,
    this.isMyPayment = false,
    this.systemSubtypeCode,
    this.timestamp,
    this.onConfirmarRecepcion,
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
          // Texto según el estado del pago
          Text(
            _getPaymentText(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Ícono de pago (SVG)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rcWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/deals/assets_temp/pago_realizado.svg',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.payment,
                  size: 35,
                  color: rcWhite,
                ),
              ),
            ),
          ),
          // Botón para confirmar recepción si es PAYMENT_MADE y no es mi pago
          if (systemSubtypeCode == 'PAYMENT_MADE' && !isMyPayment && onConfirmarRecepcion != null) ...[
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'Confirmar recepción',
              rcColor1,
              colorScheme.primary,
              onConfirmarRecepcion,
            ),
          ],
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

  String _getPaymentText() {
    if (systemSubtypeCode == 'PAYMENT_CONFIRMED') {
      return 'El pago ha sido confirmado por ambas partes';
    } else if (systemSubtypeCode == 'PAYMENT_MADE') {
      if (isMyPayment) {
        return 'Has confirmado la realización del pago';
      } else {
        return 'Se ha confirmado la realización del pago';
      }
    } else {
      // Fallback
      return isMyPayment
          ? 'Has confirmado la realización del pago'
          : 'Se ha confirmado la realización del pago';
    }
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

