// Zona táctil de la demo de gestos (módulo 2.6).
// Un GestureDetector identifica tap, doble tap, long-press y swipe.
import 'package:flutter/material.dart';

/// Área dedicada donde el usuario prueba los 4 gestos básicos.
class ZonaGestos extends StatelessWidget {
  const ZonaGestos({required this.onGesto, super.key});

  /// Callback (gesto, detalle) hacia la pantalla.
  final void Function(String gesto, [String detalle]) onGesto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Zona de gestos: toca, toca dos veces, mantén o desliza',
      child: GestureDetector(
        onTap: () => onGesto('toque simple'),
        onDoubleTap: () => onGesto('doble toque'),
        onLongPress: () => onGesto('pulsación larga'),
        onHorizontalDragEnd: (detalles) {
          final direccion = (detalles.primaryVelocity ?? 0) >= 0
              ? 'hacia la derecha'
              : 'hacia la izquierda';
          onGesto('deslizamiento', ' $direccion');
        },
        onVerticalDragEnd: (detalles) {
          final direccion = (detalles.primaryVelocity ?? 0) >= 0
              ? 'hacia abajo'
              : 'hacia arriba';
          onGesto('deslizamiento', ' $direccion');
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              'Zona de gestos\nToca · doble toca · mantén · desliza',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
