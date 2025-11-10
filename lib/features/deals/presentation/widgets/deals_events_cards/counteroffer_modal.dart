import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

class CounterofferModal extends StatefulWidget {
  final double precioActual;
  final Function(double) onRealizarContraoferta;

  const CounterofferModal({
    super.key,
    required this.precioActual,
    required this.onRealizarContraoferta,
  });

  @override
  State<CounterofferModal> createState() => _CounterofferModalState();
}

class _CounterofferModalState extends State<CounterofferModal> {
  late double _precioActual;
  final TextEditingController _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _precioActual = widget.precioActual;
    _precioController.text = _precioActual.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  void _incrementarPrecio() {
    setState(() {
      _precioActual += 100;
      _precioController.text = _precioActual.toStringAsFixed(0);
    });
  }

  void _decrementarPrecio() {
    if (_precioActual > 100) {
      setState(() {
        _precioActual -= 100;
        _precioController.text = _precioActual.toStringAsFixed(0);
      });
    }
  }

  void _onPrecioChanged(String value) {
    final precio = double.tryParse(value);
    if (precio != null && precio > 0) {
      setState(() {
        _precioActual = precio;
      });
    }
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
                  'Contraoferta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: rcColor6,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Ícono de martillo (SVG)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: rcColor7,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'lib/features/deals/assets_temp/contraoferta.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Icon(
                        Icons.gavel,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Precio actual
                Text(
                  'Precio actual:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rcColor8,
                      ),
                ),
                const SizedBox(height: 8),

                // Campo de precio
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: rcColor1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        's/',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _precioController,
                          onChanged: _onPrecioChanged,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botones +100 y -100
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIncrementButton(
                      '-100',
                      _decrementarPrecio,
                      colorScheme,
                    ),
                    const SizedBox(width: 12),
                    _buildIncrementButton(
                      '+100',
                      _incrementarPrecio,
                      colorScheme,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón Realizar Contraoferta
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
                          widget.onRealizarContraoferta(_precioActual);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Realizar Contraoferta',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncrementButton(
    String label,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rcColor6,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

