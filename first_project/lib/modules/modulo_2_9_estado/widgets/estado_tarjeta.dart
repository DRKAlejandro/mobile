// Tarjeta de resumen del estado (módulo 2.9).
// Muestra red + batería en una caja de resumen.
import 'package:flutter/material.dart';

/// Resumen visible del estado actual del dispositivo.
class EstadoTarjeta extends StatelessWidget {
  const EstadoTarjeta({required this.red, required this.bateria, super.key});

  /// Texto del estado de red.
  final String red;

  /// Texto del nivel/estado de batería.
  final String bateria;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Red: $red',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
              )),
          const SizedBox(height: 4),
          Text('Batería: $bateria',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
              )),
        ],
      ),
    );
  }
}
