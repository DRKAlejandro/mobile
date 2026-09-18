// Resumen visible del estado elegido (módulo 2.5).
// Refleja radio + checkbox + select en un solo texto de resumen.
import 'package:flutter/material.dart';

/// Caja de resumen del estado de selección actual.
class ResumenSeleccion extends StatelessWidget {
  const ResumenSeleccion({
    required this.radio,
    required this.checkbox,
    required this.pais,
    super.key,
  });

  /// Valor actual del grupo de radio.
  final String radio;

  /// Estado actual de la casilla.
  final bool checkbox;

  /// País elegido (nombre visible).
  final String pais;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary),
      ),
      child: Text(
        'Elegido → opción: $radio · términos: '
        '${checkbox ? "aceptados" : "no aceptados"} · país: $pais',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
