import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Fondo con gradiente borroso de Red Carga
class RcBackground extends StatelessWidget {
  final Widget? child;

  const RcBackground({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: rcWhite,
      child: CustomPaint(
        painter: RcBackgroundPainter(),
        size: Size.infinite,
        child: child,
      ),
    );
  }
}

class RcBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Crear paint con blur
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 250);

    // Óvalo rojo (izquierda)
    paint.color = rcColor5.withOpacity(0.65);
    canvas.drawOval(
      Rect.fromLTWH(
        -1.00 * w,
        0.17 * h,
        1.54 * w,
        1.05 * h,
      ),
      paint,
    );

    // Óvalo naranja (centro arriba)
    paint.color = rcColor2.withOpacity(0.50);
    canvas.drawOval(
      Rect.fromLTWH(
        0.40 * w,
        -0.33 * h,
        1.39 * w,
        0.89 * h,
      ),
      paint,
    );

    // Óvalo rosa (derecha)
    paint.color = rcColor3.withOpacity(0.90);
    canvas.drawOval(
      Rect.fromLTWH(
        0.54 * w,
        0.40 * h,
        1.47 * w,
        0.71 * h,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


