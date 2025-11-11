import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

class RatingModal extends StatefulWidget {
  final Function(int rating, String comment) onCalificar;

  const RatingModal({
    super.key,
    required this.onCalificar,
  });

  @override
  State<RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
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
                  'Calificar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: rcColor6,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Ícono de calificación (SVG)
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
                      'lib/features/deals/assets_temp/calificacion.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Icon(
                        Icons.star,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Estrellas interactivas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating
                              ? colorScheme.primary
                              : rcColor8,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Campo de comentario
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Deja tu comentario',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: rcColor8,
                        ),
                    filled: true,
                    fillColor: rcColor7,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: rcColor8.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: rcColor8.withOpacity(0.3),
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
                ),
                const SizedBox(height: 32),

                // Botón Publicar calificación
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
                          if (_rating > 0) {
                            Navigator.of(context).pop();
                            widget.onCalificar(
                              _rating,
                              _commentController.text.trim(),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Publicar calificación',
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

