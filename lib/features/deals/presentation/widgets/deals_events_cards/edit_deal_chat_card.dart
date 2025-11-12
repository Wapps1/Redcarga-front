import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditDealChatCard extends StatelessWidget {
  final bool acceptedDeal;
  final bool isMyEdit; // true si el usuario actual hizo la edición

  const EditDealChatCard({
    super.key,
    required this.acceptedDeal,
    this.isMyEdit = false,
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
          // Texto principal
          Text(
            'Haz editado el Documento',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcWhite,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          if (acceptedDeal) ...[
            const SizedBox(height: 8),
            Text(
              'Esperando confirmación para editar la cotización',
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
                'lib/features/deals/assets_temp/documento_editar.svg',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  rcWhite,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.edit_document,
                  size: 35,
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

