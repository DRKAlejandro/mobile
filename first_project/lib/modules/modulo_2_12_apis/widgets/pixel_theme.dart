// Tema 8-bits exclusivo del módulo 2.12 (Pokédex / GameBoy).
// Qué muestra: paleta, textos monoespaciados y decoraciones "píxel"
// (bordes negros duros + sombra maciza) solo para la pantalla de APIs.
// No toca el tema global de la app.
import 'package:flutter/material.dart';

/// Paleta Pokédex / GameBoy usada solo en la pantalla 2.12.
class PixelPoke {
  const PixelPoke._();

  /// Rojo Pokédex (AppBar, botón Buscar, luces).
  static const rojo = Color(0xFFEE1510);

  /// Rojo oscuro para sombras y bordes degradados.
  static const rojoOscuro = Color(0xFF9E0B09);

  /// Azul Pokédex (cabecera de ficha, luz grande).
  static const azul = Color(0xFF2A75BB);

  /// Azul oscuro de la pantalla GameBoy.
  static const azulOscuro = Color(0xFF1B4F7A);

  /// Amarillo chispa (fondo de ficha, botón aleatorio).
  static const amarillo = Color(0xFFFFCB05);

  /// Amarillo quemado para bordes/sombras.
  static const amarilloOscuro = Color(0xFFC7A008);

  /// Verde pantalla GameBoy (fondo de la pantalla).
  static const verdePantalla = Color(0xFF9BBC0F);

  /// Verde claro del fondo general (exterior de la consola).
  static const fondoConsola = Color(0xFFE3E6C8);

  /// Tinta casi negra para bordes y textos píxel.
  static const tinta = Color(0xFF212121);

  /// Blanco diálogo Pokémon.
  static const dialogo = Color(0xFFF8F8F0);

  /// Gris rejilla del fondo de la imagen.
  static const rejilla = Color(0xFFD8DCB8);

  /// Estilo "8-bits": monoespaciado, mayúsculas, grueso.
  static TextStyle pixel([double size = 14, Color color = tinta]) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Courier New', 'monospace'],
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        height: 1.4,
        color: color,
      );

  /// Texto con sombra dura estilo arcade.
  static TextStyle pixelSombra([double size = 14, Color color = dialogo]) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Courier New', 'monospace'],
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        height: 1.4,
        color: color,
        shadows: const [
          Shadow(offset: Offset(2, 2), color: tinta),
        ],
      );

  /// Caja diálogo Pokémon: blanca, borde negro grueso y sombra maciza.
  static BoxDecoration dialogoPoke({Color fondo = dialogo}) => BoxDecoration(
        color: fondo,
        border: Border.all(color: tinta, width: 4),
        boxShadow: const [
          BoxShadow(color: tinta, offset: Offset(6, 6)),
        ],
      );

  /// Caja de consola exterior (borde + sombra dura).
  static BoxDecoration consola({Color fondo = amarillo}) => BoxDecoration(
        color: fondo,
        border: Border.all(color: tinta, width: 4),
        boxShadow: const [
          BoxShadow(color: tinta, offset: Offset(6, 6)),
        ],
      );

  /// Color oficial aproximado por tipo de pokémon.
  static Color colorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'electric':
        return const Color(0xFFF7D02C);
      case 'fire':
        return const Color(0xFFEE8130);
      case 'water':
        return const Color(0xFF6390F0);
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'psychic':
        return const Color(0xFFF95587);
      case 'ice':
        return const Color(0xFF96D9D6);
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'dark':
        return const Color(0xFF705746);
      case 'fairy':
        return const Color(0xFFD685AD);
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'flying':
        return const Color(0xFFA98FF3);
      case 'poison':
        return const Color(0xFFA33EA1);
      case 'ground':
        return const Color(0xFFE2BF65);
      case 'rock':
        return const Color(0xFFB6A136);
      case 'bug':
        return const Color(0xFFA6B91A);
      case 'ghost':
        return const Color(0xFF735797);
      case 'steel':
        return const Color(0xFFB7B7CE);
      case 'normal':
        return const Color(0xFFA8A77A);
      default:
        return const Color(0xFFBDBDBD);
    }
  }

  /// Color de la barra de stat estilo juegos (verde → amarillo → rojo).
  static Color colorStat(int valor) {
    if (valor >= 70) return const Color(0xFF4CAF50);
    if (valor >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}
