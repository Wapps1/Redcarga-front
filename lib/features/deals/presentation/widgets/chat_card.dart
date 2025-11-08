import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class ChatCard extends StatelessWidget {
  final String nombre;
  final String ultimoMensaje;
  final String hora;
  final bool tieneMensajesNoLeidos;
  final int cantidadNoLeidos;
  final VoidCallback? onTap;

  const ChatCard({
    super.key,
    required this.nombre,
    required this.ultimoMensaje,
    required this.hora,
    this.tieneMensajesNoLeidos = false,
    this.cantidadNoLeidos = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: rcColor1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido del chat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y hora
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: rcColor6,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          hora,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: rcColor8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Último mensaje
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ultimoMensaje,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: rcColor8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (tieneMensajesNoLeidos && cantidadNoLeidos > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                cantidadNoLeidos > 9 ? '9+' : '$cantidadNoLeidos',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: rcWhite,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else if (tieneMensajesNoLeidos)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
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

