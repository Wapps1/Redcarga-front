import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AcceptDealChatCard extends StatelessWidget {
  final bool isMyAcceptance; // true si el usuario actual aceptó el trato
  final String? fleet; // Flota asignada (solo para proveedor)
  final String? driver; // Conductor asignado (solo para proveedor)
  final String? status; // PENDIENTE o CONFIRMADA
  final int? acceptanceId; // ID de la aceptación
  final int? initiatorUserId; // ID del usuario que inició la aceptación
  final int? currentUserId; // ID del usuario actual
  final DateTime? timestamp; // Timestamp del mensaje
  final VoidCallback? onAceptar; // Callback para aceptar
  final VoidCallback? onRechazar; // Callback para rechazar

  const AcceptDealChatCard({
    super.key,
    this.isMyAcceptance = false,
    this.fleet,
    this.driver,
    this.status,
    this.acceptanceId,
    this.initiatorUserId,
    this.currentUserId,
    this.timestamp,
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
          // Texto según el estado
          Text(
            status == 'CONFIRMADA'
                ? 'El trato ha sido aceptado por ambas partes'
                : isMyAcceptance
                    ? 'Has solicitado aceptar el trato'
                    : 'Se ha solicitado aceptar el trato',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Ícono de aceptar trato (SVG)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rcWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/deals/assets_temp/aceptar_trato.svg',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.handshake,
                  size: 35,
                  color: rcWhite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mensaje adicional según el estado
          if (status != 'CONFIRMADA')
          Text(
              status == 'PENDIENTE' && initiatorUserId != null && currentUserId != null && initiatorUserId != currentUserId
                  ? 'Confirma o rechaza la solicitud de aceptación'
                  : 'Espera la confirmación para formalizar el trato',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: rcWhite.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
          ),
          // Mostrar botones de acción si está pendiente y el usuario actual no es el iniciador
          if (status == 'PENDIENTE' && 
              acceptanceId != null && 
              initiatorUserId != null && 
              currentUserId != null && 
              initiatorUserId != currentUserId &&
              onAceptar != null &&
              onRechazar != null) ...[
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
          // Mostrar flota y conductor si están asignados (solo para proveedor)
          if (fleet != null && driver != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rcWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flota asignada: $fleet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: rcWhite,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Conductor asignado: $driver',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: rcWhite,
                        ),
                  ),
                ],
              ),
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

