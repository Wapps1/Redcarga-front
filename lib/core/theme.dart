import 'package:flutter/material.dart';

// Colores de Red Carga
class RcColors {
  static const Color rcColor1 = Color(0xFFFFF9F5);
  static const Color rcColor2 = Color(0xFFFEC6A3);
  static const Color rcColor3 = Color(0xFFF3C4BE);
  static const Color rcColor4 = Color(0xFFEC8366);
  static const Color rcColor5 = Color(0xFFF26A6C);
  static const Color rcColor6 = Color(0xFF3D3D3D);
  static const Color rcColor7 = Color(0xFFF8EBE2);
  static const Color rcColor8 = Color(0xFF9D9D9D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFB3261E);
}

// Tema de Red Carga
class RedcargaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: RcColors.rcColor4,
        onPrimary: RcColors.white,
        primaryContainer: RcColors.rcColor2,
        onPrimaryContainer: RcColors.rcColor6,
        secondary: RcColors.rcColor5,
        onSecondary: RcColors.white,
        secondaryContainer: RcColors.rcColor3,
        onSecondaryContainer: RcColors.rcColor6,
        tertiary: RcColors.rcColor3,
        onTertiary: RcColors.rcColor6,
        tertiaryContainer: RcColors.rcColor7,
        onTertiaryContainer: RcColors.rcColor6,
        background: RcColors.rcColor1,
        onBackground: RcColors.rcColor6,
        surface: RcColors.rcColor1,
        onSurface: RcColors.rcColor6,
        surfaceVariant: RcColors.rcColor7,
        onSurfaceVariant: RcColors.rcColor6,
        outline: RcColors.rcColor8,
        error: RcColors.error,
        onError: RcColors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: RcColors.rcColor6,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: RcColors.rcColor6,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: RcColors.rcColor6,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: RcColors.rcColor6,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: RcColors.rcColor6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: RcColors.rcColor6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: RcColors.rcColor6,
        ),
      ),
    );
  }
}

