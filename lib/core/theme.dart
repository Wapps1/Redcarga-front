import 'package:flutter/material.dart';

// ==========================
// RedCarga — Material 3 Theme
// (adaptado desde tu Compose theme.kt / color.kt / type.kt)
// ==========================

// ---- Paleta base (Compose -> Flutter) ----
const Color rcColor1 = Color(0xFFFFF9F5); // background/surface light
const Color rcColor2 = Color(0xFFFEC6A3); // primaryContainer light
const Color rcColor3 = Color(0xFFF3C4BE); // secondaryContainer / tertiary
const Color rcColor4 = Color(0xFFEC8366); // primary
const Color rcColor5 = Color(0xFFF26A6C); // secondary
const Color rcColor6 = Color(0xFF3D3D3D); // on* (gris oscuro)
const Color rcColor7 = Color(0xFFF8EBE2); // surfaceVariant light / tertiaryContainer
const Color rcColor8 = Color(0xFF9D9D9D); // outline

const Color rcWhite = Color(0xFFFFFFFF);
const Color rcBlack = Color(0xFF000000);
const Color rcError = Color(0xFFB3261E);

// ----------------------
// Tipografía Montserrat
// ----------------------
TextTheme redcargaTextTheme() => const TextTheme(
  // Display
  displayLarge: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 57, height: 1.123,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 45, height: 1.156,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 36, height: 1.222,
  ),

  // Headlines
  headlineLarge: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 32, height: 1.25,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 28, height: 1.286,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 24, height: 1.333,
  ),

  // Titles
  titleLarge: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 22, height: 1.273,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 16, height: 1.5,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 14, height: 1.429,
  ),

  // Body
  bodyLarge: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w400, fontSize: 16, height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w400, fontSize: 14, height: 1.429,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w400, fontSize: 12, height: 1.333,
  ),

  // Labels
  labelLarge: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 14, height: 1.429,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 12, height: 1.333,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 11, height: 1.455,
  ),
);

class MaterialTheme {
  final TextTheme textTheme;
  const MaterialTheme(this.textTheme);

  // ------------------
  // Light ColorScheme
  // ------------------
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: rcColor4,
      surfaceTint: rcColor4,
      onPrimary: rcWhite,
      primaryContainer: rcColor2,
      onPrimaryContainer: rcColor6,

      secondary: rcColor5,
      onSecondary: rcWhite,
      secondaryContainer: rcColor3,
      onSecondaryContainer: rcColor6,

      tertiary: rcColor3,
      onTertiary: rcColor6,
      tertiaryContainer: rcColor7,
      onTertiaryContainer: rcColor6,

      error: rcError,
      onError: rcWhite,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF690005),

      surface: rcColor1,
      onSurface: rcColor6,
      onSurfaceVariant: rcColor6,
      outline: rcColor8,
      outlineVariant: Color(0xFFC8C8C8),
      shadow: rcBlack,
      scrim: Color(0x52000000), // 32% negro

      inverseSurface: Color(0xFF121212),
      onInverseSurface: Color(0xFFEAEAEA),
      inversePrimary: rcColor5,

      // Estos campos existen en M3; si tu SDK aún no los expone, puedes quitarlos.
      surfaceContainerLowest: rcWhite,
      surfaceContainerLow: Color(0xFFF3F0EC),
      surfaceContainer: Color(0xFFEDE7E2),
      surfaceContainerHigh: Color(0xFFE7E1DC),
      surfaceContainerHighest: Color(0xFFE2DDD7),
      surfaceDim: Color(0xFFDCD6D1),
      surfaceBright: rcColor1,
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  // -----------------
  // Dark ColorScheme
  // -----------------
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: rcColor4,
      surfaceTint: rcColor4,
      onPrimary: rcWhite,
      primaryContainer: rcColor5,
      onPrimaryContainer: rcWhite,

      secondary: rcColor5,
      onSecondary: rcWhite,
      secondaryContainer: rcColor4,
      onSecondaryContainer: rcWhite,

      tertiary: rcColor3,
      onTertiary: rcColor6,
      tertiaryContainer: rcColor7,
      onTertiaryContainer: rcColor6,

      error: rcError,
      onError: rcWhite,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFF2F2F2),
      onSurfaceVariant: Color(0xFFCCCCCC),
      outline: rcColor8,
      outlineVariant: Color(0xFF6E6E6E),
      shadow: rcBlack,
      scrim: Color(0x52000000),

      inverseSurface: Color(0xFFEAEAEA),
      onInverseSurface: Color(0xFF121212),
      inversePrimary: rcColor4,

      surfaceContainerLowest: Color(0xFF0E0E0E),
      surfaceContainerLow: Color(0xFF191919),
      surfaceContainer: Color(0xFF232323),
      surfaceContainerHigh: Color(0xFF2D2D2D),
      surfaceContainerHighest: Color(0xFF373737),
      surfaceDim: Color(0xFF111111),
      surfaceBright: Color(0xFF2C2C2C),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  // -----------------
  // Theme builder
  // -----------------
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => const [];
}

// (Opcional) Soporte para familias extendidas como en el ejemplo del profe
class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

// -----------------
// Uso (ejemplo):
// final materialTheme = MaterialTheme(redcargaTextTheme());
// MaterialApp(
//   theme: materialTheme.light(),
//   darkTheme: materialTheme.dark(),
//   themeMode: ThemeMode.system,
// );
// -----------------
