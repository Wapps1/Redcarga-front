import 'package:flutter/material.dart';
import '../theme.dart';

/// Botón de retroceso de Red Carga
class RcBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RcBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
      color: RcColors.rcColor6,
      iconSize: 24,
    );
  }
}

