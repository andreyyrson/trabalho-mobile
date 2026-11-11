// Visual identity shared by the visitor app and the admin panel.
import 'package:flutter/material.dart';

// Amazon-inspired: forest green for the brand, amber for the surprise mission.
const corMarca = Color(0xFF0E7C5A);
const corMissao = Color(0xFFFFB300);

ThemeData tema(Brightness brilho) {
  final cores = ColorScheme.fromSeed(seedColor: corMarca, brightness: brilho);
  return ThemeData(
    colorScheme: cores,
    scaffoldBackgroundColor: cores.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cores.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cores.primary,
      foregroundColor: cores.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// Brand gradient used on headers.
LinearGradient gradienteMarca(ColorScheme cores) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cores.primary, Color.lerp(cores.primary, cores.tertiary, 0.7)!],
    );

const gradienteMissao = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFC94A), Color(0xFFFF8F00)],
);
