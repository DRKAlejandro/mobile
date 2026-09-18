// Lectura visible de los tres ejes (módulo 2.8).
// Muestra X/Y/Z en m/s² con una fila por eje.
import 'package:flutter/material.dart';

/// Tarjeta con los valores actuales del acelerómetro.
class LecturaEjes extends StatelessWidget {
  const LecturaEjes({
    required this.x,
    required this.y,
    required this.z,
    super.key,
  });

  /// Aceleración en cada eje (m/s²).
  final double x;
  final double y;
  final double z;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _FilaEje(eje: 'X', valor: x),
            _FilaEje(eje: 'Y', valor: y),
            _FilaEje(eje: 'Z', valor: z),
          ],
        ),
      ),
    );
  }
}

/// Una fila eje + valor numérico.
class _FilaEje extends StatelessWidget {
  const _FilaEje({required this.eje, required this.valor});

  final String eje;
  final double valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Eje $eje', style: Theme.of(context).textTheme.titleSmall),
          Text('${valor.toStringAsFixed(2)} m/s²'),
        ],
      ),
    );
  }
}
