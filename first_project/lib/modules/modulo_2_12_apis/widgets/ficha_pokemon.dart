// Ficha visual del módulo 2.12 · estilo 8-bits Pokédex (FR-005).
// Qué muestra: tarjeta amarilla de consola con cabecera azul, sprite
// pixelado sobre rejilla GameBoy, tipos con colores oficiales, cajitas
// de altura/peso y barras de stats estilo HP de los juegos.
// La imagen usa `Image.network` con `filterQuality.none` (look pixelado),
// progreso y respaldo sin red. Mantiene badge REAL/SIMULADO.
import 'package:flutter/material.dart';

import '../../../shared/widgets/simulado_badge.dart';
import '../models/pokemon.dart';
import 'pixel_theme.dart';

/// Nombre con inicial en mayúscula para exhibir (`pikachu` → `Pikachu`).
String capitalizar(String nombre) => nombre.isEmpty
    ? nombre
    : nombre[0].toUpperCase() + nombre.substring(1);

/// Ficha completa de un pokémon (dato real o simulado).
class FichaPokemon extends StatelessWidget {
  const FichaPokemon({required this.pokemon, super.key});

  /// Pokémon a exhibir.
  final Pokemon pokemon;

  /// Sprite sobre fondo de rejilla GameBoy, pixelado a propósito.
  Widget _imagen() {
    final Widget contenido = pokemon.imagenUrl.isEmpty
        ? const Icon(Icons.catching_pokemon,
            size: 96, semanticLabel: 'Sin imagen')
        : Image.network(
            pokemon.imagenUrl,
            height: 168,
            // Sin suavizado: los sprites se ven "8-bits".
            filterQuality: FilterQuality.none,
            semanticLabel: 'Imagen de ${pokemon.nombre}',
            loadingBuilder: (context, child, progreso) => progreso == null
                ? child
                : const SizedBox(
                    height: 168,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: PixelPoke.rojo,
                        semanticsLabel: 'Cargando imagen',
                      ),
                    ),
                  ),
            errorBuilder: (context, error, pila) =>
                const Icon(Icons.catching_pokemon,
                    size: 96,
                    semanticLabel: 'Imagen no disponible sin conexión'),
          );
    return Container(
      height: 192,
      decoration: BoxDecoration(
        color: PixelPoke.verdePantalla,
        border: Border.all(color: PixelPoke.tinta, width: 4),
      ),
      child: CustomPaint(
        painter: _RejillaPainter(),
        child: Center(child: contenido),
      ),
    );
  }

  /// Etiqueta de tipo con su color oficial y borde píxel.
  Widget _tipoChip(String tipo) {
    final fondo = PixelPoke.colorTipo(tipo);
    // Texto oscuro en tipos claros, blanco en oscuros.
    final oscuro = tipo == 'electric' ||
        tipo == 'ice' ||
        tipo == 'ground' ||
        tipo == 'grass' ||
        tipo == 'normal' ||
        tipo == 'steel' ||
        tipo == 'fairy' ||
        tipo == 'bug';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: PixelPoke.tinta, width: 3),
        boxShadow: const [
          BoxShadow(color: PixelPoke.tinta, offset: Offset(3, 3)),
        ],
      ),
      child: Text(
        tipo.toUpperCase(),
        style: PixelPoke.pixel(
            12, oscuro ? PixelPoke.tinta : PixelPoke.dialogo),
      ),
    );
  }

  /// Cajita de dato (altura / peso) estilo pantalla de estado.
  Widget _datoCaja(String etiqueta, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: PixelPoke.dialogo,
          border: Border.all(color: PixelPoke.tinta, width: 3),
        ),
        child: Column(
          children: [
            Text(etiqueta, style: PixelPoke.pixel(11, PixelPoke.azulOscuro)),
            const SizedBox(height: 4),
            Text(valor, style: PixelPoke.pixel(14)),
          ],
        ),
      ),
    );
  }

  /// Barra de stat estilo HP de los juegos (nombre + barra + valor).
  Widget _barraStat(String nombre, int valor) {
    final proporcion = (valor.clamp(0, 120)) / 120;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              nombre.toUpperCase(),
              style: PixelPoke.pixel(11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: PixelPoke.dialogo,
                border: Border.all(color: PixelPoke.tinta, width: 3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: proporcion == 0 ? 0.02 : proporcion,
                child: Container(color: PixelPoke.colorStat(valor)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$valor',
              textAlign: TextAlign.right,
              style: PixelPoke.pixel(12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pokemon;
    return Semantics(
      label:
          'Ficha de ${capitalizar(p.nombre)}, número ${p.id}, ${p.esReal ? "dato real" : "dato simulado"}',
      child: Container(
        decoration: PixelPoke.consola(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera azul Pokédex con número y nombre.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: PixelPoke.azul,
                border: Border(
                  bottom: BorderSide(color: PixelPoke.tinta, width: 4),
                ),
              ),
              child: Row(
                children: [
                  // Luz de consola.
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: p.esReal
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFFC107),
                      shape: BoxShape.circle,
                      border: Border.all(color: PixelPoke.dialogo, width: 2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '#${p.id.toString().padLeft(3, '0')}  ${capitalizar(p.nombre).toUpperCase()}',
                      style: PixelPoke.pixelSombra(16),
                    ),
                  ),
                  SimuladoBadge(esReal: p.esReal),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _imagen(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final tipo in p.tipos) _tipoChip(tipo),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _datoCaja(
                          'ALTURA', '${p.alturaM.toStringAsFixed(1)} m'),
                      const SizedBox(width: 10),
                      _datoCaja('PESO', '${p.pesoKg.toStringAsFixed(1)} kg'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PixelPoke.dialogo,
                      border: Border.all(color: PixelPoke.tinta, width: 3),
                    ),
                    child: Text(
                      'HABILIDADES: ${p.habilidades.map((h) => '${h.nombre.toUpperCase()}${h.oculta ? " (OCULTA)" : ""}').join(" / ")}',
                      style: PixelPoke.pixel(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PixelPoke.verdePantalla.withValues(alpha: 0.35),
                      border: Border.all(color: PixelPoke.tinta, width: 3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('>> STATS BASE',
                            style: PixelPoke.pixel(12, PixelPoke.azulOscuro)),
                        const SizedBox(height: 6),
                        for (final s in p.stats)
                          _barraStat(s.nombre, s.valor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rejilla fina estilo pantalla GameBoy detrás del sprite.
class _RejillaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lapiz = Paint()
      ..color = PixelPoke.rejilla
      ..strokeWidth = 1;
    const paso = 16.0;
    for (var x = paso; x < size.width; x += paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lapiz);
    }
    for (var y = paso; y < size.height; y += paso) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lapiz);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
