import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

class EditDealModal extends StatefulWidget {
  final bool acceptedDeal;
  final Function(String motivo) onActualizarCotizacion;
  final Function(String motivo) onEnviarSolicitud;

  const EditDealModal({
    super.key,
    required this.acceptedDeal,
    required this.onActualizarCotizacion,
    required this.onEnviarSolicitud,
  });

  @override
  State<EditDealModal> createState() => _EditDealModalState();
}

class _EditDealModalState extends State<EditDealModal> {
  final TextEditingController _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: rcColor1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Editar trato',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: rcColor6,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Ícono de documento con lápiz
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: rcColor7,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'lib/features/deals/assets_temp/edicion_documento.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Icon(
                        Icons.edit_document,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
/*
                // Campo de texto para el motivo
                TextField(
                  controller: _motivoController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Cuéntanos tu motivo',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: rcColor8,
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.secondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.secondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rcColor6,
                      ),
                ),
                const SizedBox(height: 32),
                */

                // Botón según el estado
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // El input de motivo está comentado, usar string vacío
                          final motivo = ''; // _motivoController.text.trim();
                            // No cerrar aquí, dejar que el callback maneje el cierre
                            if (widget.acceptedDeal) {
                              widget.onEnviarSolicitud(motivo);
                            } else {
                            // Ejecutar el callback async en el siguiente frame para evitar bloqueos
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              widget.onActualizarCotizacion(motivo);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              widget.acceptedDeal
                                  ? 'Enviar solicitud de cotización'
                                  : 'Actualizar cotización',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: rcWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón Cancelar
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancelar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

