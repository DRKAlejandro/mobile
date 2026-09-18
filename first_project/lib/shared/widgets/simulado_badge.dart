// Etiqueta visible que distingue lecturas REALES de valores SIMULADOS (FR-013).
// Toda demo de sensor, mapa o notificación MUST mostrar este badge.
import 'package:flutter/material.dart';

/// Badge REAL (verde) o SIMULADO (ámbar).
class SimuladoBadge extends StatelessWidget {
  const SimuladoBadge({required this.esReal, super.key});

  /// `true` → lectura real del dispositivo; `false` → valor ilustrativo.
  final bool esReal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: esReal ? 'Lectura real del dispositivo' : 'Valor simulado con fines demostrativos',
      child: Chip(
        label: Text(esReal ? 'REAL' : 'SIMULADO'),
        backgroundColor: esReal ? Colors.green.shade100 : Colors.amber.shade100,
        side: BorderSide(
          color: esReal ? Colors.green.shade700 : Colors.amber.shade800,
        ),
      ),
    );
  }
}
