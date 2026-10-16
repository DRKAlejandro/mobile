// Tema anaranjado de la pizzería (T005, US4).
// Un solo punto de definición: `ColorScheme.fromSeed` con semilla
// naranja + Material 3. Los textos sobre colores principales usan
// siempre sus roles `on-` para garantizar contraste (SC-004).
import 'package:flutter/material.dart';

/// Paleta y tema de pizza_pizza.
class AppTheme {
  const AppTheme._();

  /// Naranja principal de la marca.
  static const Color naranja = Color(0xFFEA6A00);

  /// Acento ámbar para detalles secundarios.
  static const Color ambar = Color(0xFFFFB300);

  /// Fondo cálido claro.
  static const Color fondoCalido = Color(0xFFFFF7ED);

  /// Tema claro de la app.
  static ThemeData get claro {
    final scheme = ColorScheme.fromSeed(
      seedColor: naranja,
      secondary: ambar,
      surface: fondoCalido,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: fondoCalido,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}
