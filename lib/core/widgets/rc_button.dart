import 'package:flutter/material.dart';
import '../theme.dart';

/// Botón primario de Red Carga
class RcButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const RcButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 52,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: rcWhite,
          foregroundColor: rcColor6,
          disabledBackgroundColor:rcWhite.withOpacity(0.5),
          disabledForegroundColor: rcColor6.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(rcColor6),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Botón secundario de Red Carga (outlined)
class RcOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const RcOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 52,
      child: OutlinedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: rcWhite.withOpacity(0.15),
          foregroundColor: rcWhite.withOpacity(0.90),
          disabledBackgroundColor: rcWhite.withOpacity(0.05),
          disabledForegroundColor: rcWhite.withOpacity(0.4),
          side: const BorderSide(color: rcWhite, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(rcWhite),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}


