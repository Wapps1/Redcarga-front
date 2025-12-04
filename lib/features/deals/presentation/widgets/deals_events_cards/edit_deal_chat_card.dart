import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditDealChatCard extends StatelessWidget {
  final bool acceptedDeal;
  final bool isMyEdit; // true si el usuario actual hizo la edición
  final String? statusCode; // PENDIENTE o APLICADO
  final DateTime? timestamp; // Timestamp del mensaje
  final VoidCallback? onVerCotizacion; // Para ver la cotización con cambios

  const EditDealChatCard({
    super.key,
    required this.acceptedDeal,
    this.isMyEdit = false,
    this.statusCode,
    this.timestamp,
    this.onVerCotizacion,
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
            colorScheme.primaryContainer,
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.secondaryContainer,
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
          // Texto principal según quién hizo la edición
          Text(
            isMyEdit
                ? 'Haz editado el Documento'
                : statusCode == 'APLICADO'
                    ? 'El documento ha sido editado y aplicado'
                    : 'Se ha editado el Documento',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          if (acceptedDeal) ...[
            const SizedBox(height: 8),
            Text(
              statusCode == 'APLICADO'
                  ? 'Los cambios han sido aplicados'
                  : isMyEdit
                      ? 'Esperando confirmación para editar la cotización'
                      : 'Confirma o rechaza la edición de la cotización',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rcWhite.withOpacity(0.9),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          // Ícono de documento con lápiz
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rcWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/deals/assets_temp/edicion_documento.svg',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                /*colorFilter: ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),*/
                placeholderBuilder: (context) => Icon(
                  Icons.edit_document,
                  size: 35,
                  color: rcWhite,
                ),
              ),
            ),
          ),
          // Botón Ver cotización (si está pendiente y no es mi edición)
          if (statusCode == 'PENDIENTE' && !isMyEdit && onVerCotizacion != null) ...[
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'Ver cotización',
              rcColor1,
              colorScheme.primary,
              onVerCotizacion,
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

